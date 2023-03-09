from django.contrib import admin

from .models import (
    Poll,
    PollCharField,
    PollChoiceField,
    PollMultiChoiceField,
    PollTextField,
    PollCharFieldAnswer,
    PollTextFieldAnswer,
    PollChoiceFieldAnswer,
    PollMultiChoiceFieldAnswer
)

admin.site.register(Poll)
admin.site.register(PollCharField)
admin.site.register(PollTextField)
admin.site.register(PollChoiceField)
admin.site.register(PollMultiChoiceField)
admin.site.register(PollCharFieldAnswer, )
admin.site.register(PollTextFieldAnswer, )
admin.site.register(PollChoiceFieldAnswer, )
admin.site.register(PollMultiChoiceFieldAnswer)
