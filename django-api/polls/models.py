from django.db import models
from django.contrib.postgres.fields import ArrayField
from authentication.models import User


class Poll(models.Model):
    title = models.CharField('Poll title', max_length=100)
    description = models.CharField('Description', max_length=255, blank=True)

    def __str__(self):
        return self.title[:30]


class PollCharField(models.Model):
    text = models.CharField('Question Text', max_length=100)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def __str__(self):
        return self.text[:30]


class PollCharFieldAnswer(models.Model):
    answer = models.CharField('Answer', max_length=100)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    field = models.ForeignKey(
        PollCharField,
        on_delete=models.CASCADE,
        related_name='char_field_answers',
        related_query_name='char_field_answer'
    )

    class Meta:
        unique_together = ('user', 'field')

    def __str__(self):
        return self.answer[:30]


class PollTextField(models.Model):
    text = models.CharField('Question Text', max_length=100)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def __str__(self):
        return self.text[:30]


class PollTextFieldAnswer(models.Model):
    answer = models.TextField('Answer')
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    field = models.ForeignKey(
        PollTextField,
        on_delete=models.CASCADE,
        related_name='text_field_answers',
        related_query_name='text_field_answer'
    )

    class Meta:
        unique_together = ('user', 'field')

    def __str__(self):
        return self.answer[:30]


class PollChoiceField(models.Model):
    text = models.CharField('Question Text', max_length=100)
    choices = ArrayField(models.CharField('Choice', max_length=100))
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def __str__(self):
        return self.text[:30]


class PollChoiceFieldAnswer(models.Model):
    selected_choice = models.CharField('Selected Choice', max_length=100)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    field = models.ForeignKey(
        PollChoiceField,
        on_delete=models.CASCADE,
        related_name='choice_field_answers',
        related_query_name='choice_field_answer'
    )

    class Meta:
        unique_together = ('user', 'field')

    def save(self, *args, **kwargs):
        if self.selected_choice not in self.field.choices:
            return

        super().save(*args, **kwargs)

    def __str__(self):
        return self.selected_choice[:30]


class PollMultiChoiceField(models.Model):
    text = models.CharField('Question Text', max_length=100)
    choices = ArrayField(models.CharField('Choice', max_length=100))
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def __str__(self):
        return self.text[:30]


class PollMultiChoiceFieldAnswer(models.Model):
    selected_choices = ArrayField(
        models.CharField('Selected Choices', max_length=100))
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    field = models.ForeignKey(
        PollMultiChoiceField,
        on_delete=models.CASCADE,
        related_name='multichoice_field_answers',
        related_query_name='multichoice_field_answer'

    )

    class Meta:
        unique_together = ('user', 'field')

    def save(self, *args, **kwargs):
        for choice in self.selected_choices:
            if choice not in self.field.choices:
                return

        super().save(*args, **kwargs)
