> [!INFO]
> This is some example output from `$spec-mode`.

# Add `--name` flag to workmux add command

## Initial ask

Add `--name <name>` flag to the `workmux add` command to name the worktree independently from the branch name.

**Rationale:** Branch names can be very long and don't make good worktree names.

## Research findings

### Current architecture

The codebase conflates branch names and worktree names in several places:

1. **Worktree path creation** (`src/workflow/create.rs:134`):
   - `let worktree_path = base_dir.join(branch_name);`
   - Directly uses branch name as directory name

2. **Tmux window naming** (throughout):
   - `tmux::window_exists(&context.prefix, branch_name)?`
   - Uses branch name as tmux window name

3. **Worktree lookup** (`src/git.rs:305-320`):
   - `get_worktree_path(branch_name)` - finds worktree by branch
   - Returns worktree path from git's internal mapping

4. **Git worktree API**:
   - Git maintains mapping: worktree_path ↔ branch_name
   - Not dependent on directory names

### Key insight

The worktree directory name is cosmetic. Git tracks worktrees by their absolute path, not by directory name. The branch is what matters to git.

Therefore:
- Worktree path can use custom name
- Branch name remains unchanged
- Git's internal mapping handles the rest
- Tmux window name should also use custom name for consistency

## Changes needed

1. **Worktree path:** Use custom name instead of branch name
2. **Tmux window:** Use custom name instead of branch name
3. **All lookups:** Must continue using branch name (git API requirement)
4. **Display logic:** Show both worktree name and branch name where relevant

## Implementation plan

### Data models

Add `worktree_name` field alongside `branch_name`:

```rust
// src/workflow/types.rs
pub struct CreateResult {
    pub worktree_path: PathBuf,
    pub branch_name: String,
    pub worktree_name: String,     // [🟢 NEW]
    pub post_create_hooks_run: usize,
    pub base_branch: Option<String>,
}
```

### Pseudocode breakdown

`[A]` **CLI argument parsing** - accept optional `--name` flag

```sh
# == src/command/args.rs ==
# (no changes needed - just pass through to command/add.rs)
```

`[B]` **Command handler** - process name argument

```sh
# == src/command/add.rs ==

run(branch_name, pr, base, name, ...) # [🟡 UPDATED: add name param]
  → worktree_name = name.unwrap_or(branch_name) # [🟢 NEW]
  → pass worktree_name through to workflow::create() # [🟡 UPDATED]
```

`[C]` **Worktree creation** - use custom name for paths and tmux

```sh
# == src/workflow/create.rs ==

create(branch_name, worktree_name, ...) # [🟡 UPDATED: add worktree_name param]
  → validate_tmux_window(worktree_name) # [🟡 UPDATED: check worktree_name, not branch_name]
  → worktree_path = base_dir.join(worktree_name) # [🟡 UPDATED: use worktree_name]
  → git::create_worktree(worktree_path, branch_name, ...) # [no change - git uses branch]
  → setup_environment(worktree_name, worktree_path, ...) # [🟡 UPDATED]
  → return CreateResult { worktree_name, ... } # [🟡 UPDATED]
```

`[D]` **Environment setup** - use worktree name for tmux window

```sh
# == src/workflow/setup.rs ==

setup_environment(worktree_name, worktree_path, ...) # [🟡 UPDATED]
  → tmux::create_window(prefix, worktree_name, ...) # [🟡 UPDATED: use worktree_name]
  → tmux::select_window(prefix, worktree_name) # [🟡 UPDATED]
```

`[E]` **Multi-worktree generation** - generate names for multi mode

```sh
# == src/template.rs ==

WorktreeSpec {
    branch_name: String,
    worktree_name: String,  # [🟢 NEW]
    agent: Option<String>,
    template_context: BTreeMap<String, String>,
}

generate_worktree_specs(...) # [🟡 UPDATED]
  → for each spec:
      spec.branch_name = render(branch_template, context)
      spec.worktree_name = spec.branch_name # [🟢 NEW: default to branch name]
```

`[F]` **create_with_changes** - handle rescue mode

```sh
# == src/workflow/create.rs ==

create_with_changes(branch_name, worktree_name, ...) # [🟡 UPDATED]
  → worktree_name = worktree_name.unwrap_or(branch_name) # [🟢 NEW]
  → create(branch_name, worktree_name, ...) # [🟡 UPDATED]
```

### Files

**Modified:**
- `src/cli.rs` - add `--name` arg to add command
- `src/command/add.rs` - accept and process name parameter
- `src/workflow/create.rs` - thread worktree_name through create functions
- `src/workflow/setup.rs` - use worktree_name for tmux operations
- `src/workflow/open.rs` - unchanged (uses existing worktree lookup by branch)
- `src/workflow/types.rs` - add worktree_name to CreateResult
- `src/template.rs` - add worktree_name to WorktreeSpec
- `src/command/open.rs` - pass None for worktree_name (lookup existing)

**Reference files for LLM:**
- `src/git.rs` - git operations (no changes needed)
- `src/tmux.rs` - tmux operations (no changes needed)

### Important constraints

1. **Git operations unchanged:** All git operations continue using `branch_name` - git doesn't care about directory names
2. **Lookup operations:** Commands like `open`, `remove`, `merge` continue to lookup by branch name (git's mapping)
3. **Backwards compatibility:** When `--name` not provided, use branch name (default behavior preserved)
4. **Multi-worktree mode:** In multi mode, worktree names default to generated branch names
5. **Display output:** Show both worktree name and branch where they differ

### Testing strategy

**Manual testing:**

```sh
# Basic usage
workmux add feature/long-branch-name --name feat

# Verify worktree directory
ls ../*__worktrees/feat

# Verify tmux window
tmux list-windows | grep feat

# Verify git still tracks by branch
git worktree list
```

**Edge cases to verify:**

1. Name with special characters (should be rejected or sanitized)
2. Name collision (directory already exists)
3. Multi-worktree mode (should use branch names)
4. PR checkout mode (should allow custom name)
5. Rescue mode `--with-changes` (should support name)

