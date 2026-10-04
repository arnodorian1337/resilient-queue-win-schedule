"""Minimal queue worker used by the history fixture."""


def process(message: str) -> str:
    """Return the normalized queue message."""
    return message.strip()


if __name__ == "__main__":
    print(process("worker ready"))
