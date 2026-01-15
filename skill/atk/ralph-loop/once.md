0. Gather context
   - Read `artefacts/progress.md`
   - Read plan

2. Identify story
   - Pick one story - the most important one that's not blocked. It may not be the top-most story
   - Pick only one story, never pick more than one

3. Do task
   - Do the identified story
   - See guidelines below
   - Proceed to next step as soon as the story is done, don't proceed to other stories

4. Verify work
   - Use review-with-subagent with @general agent
   - Make judgement call on which of its feedback to address

5. Mark progress
   - update prd.md to mark things as done

6. Document learnings
   - assess the conversation, identify roadblocks, summarise work done, include assumptions flagged
   - append them in `artefacts/progress.md` (create if it doesn't exist) - this is to assist future work

7. Commit changes
   - Include story ID in commit title

8. Assess done-ness
   - Check if there are any user stories requiring action after this
   - If there are none, say: `<progress>PRD_FINISHED</progress>`
   - Else, say: `<progress>PRD_IN_PROGRESS</progress>`

Code writing guidelines:

- State assumptions before writing code.
- Verify before claiming correctness.
- Handle non-happy paths as well. Do not handle only the happy path.
- Answer: under what conditions does this work?

Other guidelines:

- Do not make a pull request
