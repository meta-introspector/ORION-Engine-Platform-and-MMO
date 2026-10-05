"""
Round Four review: the Anti-Babel filter in `ORION BUILD: DeepSeek Python` never blocks.

In that document `AntiBabelFilter.validate` is declared `async def`, but
`MycelialHighway.deposit_seed` calls it WITHOUT `await`:

    if not self.anti_babel_filter.validate(rep_seed):
        await self.anti_babel_filter.evaporate_rind(rep_seed, user_id)
        return None

Calling an async function without `await` returns a coroutine object, which is always
truthy, so `not <coroutine>` is always False and every seed is accepted, however
destructive.  This file reproduces the pattern with the filter reduced to a single rule
("reject anything") so the effect is unmistakable.

    python3 review/anti_babel_await_check.py
"""
import asyncio
import warnings


class AntiBabelFilter:
    async def validate(self, content: str) -> bool:
        return False  # reject everything


class Highway:
    def __init__(self):
        self.anti_babel_filter = AntiBabelFilter()
        self.vault = []

    async def deposit_seed_as_written(self, seed: str):
        if not self.anti_babel_filter.validate(seed):  # missing await (as in the source)
            return None
        self.vault.append(seed)
        return seed

    async def deposit_seed_fixed(self, seed: str):
        if not await self.anti_babel_filter.validate(seed):
            return None
        self.vault.append(seed)
        return seed


async def main():
    h = Highway()
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", RuntimeWarning)  # "coroutine was never awaited"
        accepted = await h.deposit_seed_as_written("destructive content")
    print("as written :", "ACCEPTED" if accepted else "blocked")
    assert accepted is not None, "expected the unawaited filter to let content through"

    blocked = await h.deposit_seed_fixed("destructive content")
    print("with await :", "ACCEPTED" if blocked else "blocked")
    assert blocked is None

    print("ALL CHECKS PASSED")


asyncio.run(main())
