from django.contrib import admin

from .models import (
    Poll,
    PollCharField,
    PollChoiceField,
    PollMultiChoiceField,
    PollTextField,
)

admin.site.register(Poll)
admin.site.register(PollCharField)
admin.site.register(PollTextField)
admin.site.register(PollChoiceField)
admin.site.register(PollMultiChoiceField)
