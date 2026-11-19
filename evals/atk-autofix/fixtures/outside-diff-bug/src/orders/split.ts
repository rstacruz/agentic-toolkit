export const MAX_CHARGE_CENTS = 500_00;

/** Splits an amount into card charges no larger than `maxCents` each. */
export function splitCharges(amountCents: number, maxCents: number = MAX_CHARGE_CENTS): number[] {
  const count = Math.ceil(amountCents / maxCents);
  const charges = new Array<number>(count).fill(maxCents);
  charges[count - 1] = amountCents - maxCents * (count - 1);
  return charges;
}
