import { $ } from 'zx'
const date = await $`date`
await $`echo Current date is ${date}.`