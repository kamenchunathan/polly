from django import forms
from django.contrib.postgres.forms import SimpleArrayField
from django.core.exceptions import ValidationError

from .models import (
    PollCharField,
    PollChoiceField,
    PollTextField,
    PollMultiChoiceField,
    PollCharFieldAnswer,
    PollChoiceFieldAnswer,
    PollMultiChoiceFieldAnswer,
    PollTextFieldAnswer
)


class PollCharFieldForm(forms.ModelForm):
    class Meta:
        model = PollCharField
        fields = ('text', 'poll')


class PollChoiceFieldForm(forms.ModelForm):
    class Meta:
        model = PollChoiceField
        fields = ('text', 'poll', 'choices')

    choices = SimpleArrayField(forms.CharField(max_length=100))


class PollTextFieldForm(forms.ModelForm):
    class Meta:
        model = PollTextField
        fields = ('text', 'poll')


class PollMultiChoiceFieldForm(forms.ModelForm):
    class Meta:
        model = PollMultiChoiceField
        fields = ('text', 'choices', 'poll')

    choices = SimpleArrayField(forms.CharField(max_length=100))


class PollCharFieldAnswerForm(forms.ModelForm):
    class Meta:
        model = PollCharFieldAnswer
        fields = ('answer', 'field')


class PollChoiceFieldAnswerForm(forms.ModelForm):
    class Meta:
        model = PollChoiceFieldAnswer
        fields = ('selected_choice', 'field')

    def clean(self):
        cleaned_data = super().clean()
        selected_choice = cleaned_data.get('selected_choice')
        poll_field = cleaned_data.get('field')
        if selected_choice not in poll_field.choices:
            raise ValidationError(
                'Selected option must be from choices in field'
                f': {poll_field.choices}'
            )


class PollMultiChoiceFieldAnswerForm(forms.ModelForm):
    class Meta:
        model = PollMultiChoiceFieldAnswer
        fields = ('selected_choices', 'field')

    def clean(self):
        cleaned_data = super().clean()
        selected_choices = cleaned_data.get('selected_choices')
        poll_field = cleaned_data.get('field')

        if poll_field is None:
            raise ValidationError('Provide a valid Id for the field')

        for selected_choice in selected_choices:
            if selected_choice not in poll_field.choices:
                raise ValidationError(
                    'Selected option must be from choices in field '
                    f'{poll_field.choices}'
                )


class PollTextFieldAnswerForm(forms.ModelForm):
    class Meta:
        model = PollTextFieldAnswer
        fields = ('answer', 'field')
