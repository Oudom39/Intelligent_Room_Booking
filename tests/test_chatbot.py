import pytest

from booking.telegram_notifications import format_support_message


def test_format_support_message_includes_expected_fields():
    message = format_support_message(
        name="Ada Lovelace",
        email="ada@example.com",
        subject="Projector not working",
        message="The projector in Lab A will not power on.",
    )

    assert "*User Issue Reported*" in message
    assert "Ada Lovelace (ada@example.com)" in message
    assert "*Subject:* Projector not working" in message
    assert "*Message:* The projector in Lab A will not power on." in message
