from django.db import models
from django.contrib.postgres.fields import ArrayField
from guardian.shortcuts import assign_perm
from django.dispatch import receiver
from django.db.models.signals import post_save
from django.contrib.auth import get_user_model


User = get_user_model()


class Poll(models.Model):
    title = models.CharField('Poll title', max_length=100)
    description = models.CharField('Description', max_length=255, blank=True)
    owner = models.ForeignKey(User, on_delete=models.CASCADE)

    class Meta:
        # The edit poll permission is for this class as well as any fields
        # associated with the poll
        #
        # The answer poll permission will be used to check whether a user
        # can answer questions (fields) on the poll
        permissions = (
            ('edit_poll', 'Can edit poll'),
            ('answer_poll', 'Can answer a poll')
        )

    def __str__(self):
        return self.title[:50]

# ------------------------------ Poll fields ---------------------------------


@receiver(post_save, sender=Poll)
def assign_user_perms(sender, instance, created, **kwargs):
    poll_owner: User = instance.owner
    if created and not poll_owner.is_anonymous:
        assign_perm('edit_poll', poll_owner, instance)


class PollCharField(models.Model):
    text = models.CharField('Question Text', max_length=100)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def __str__(self):
        return self.text[:30]


class PollTextField(models.Model):
    text = models.CharField('Question Text', max_length=100)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def __str__(self):
        return self.text[:30]


class PollChoiceField(models.Model):
    text = models.CharField('Question Text', max_length=100)
    choices = ArrayField(models.CharField('Choice', max_length=100))
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def __str__(self):
        return self.text[:30]


class PollMultiChoiceField(models.Model):
    text = models.CharField('Question Text', max_length=100)
    choices = ArrayField(models.CharField('Choice', max_length=100))
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def __str__(self):
        return self.text[:30]


# ------------------------------- Poll field --------------------------------

class PollResponse(models.Model):
    """
    A poll response. This is meant to support incomplete, unsubmitted and
    discarded responses
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE)


class PollCharFieldAnswer(models.Model):
    answer = models.CharField('Answer', max_length=100)
    response = models.ForeignKey(
        PollResponse,
        on_delete=models.CASCADE,
        null=True
    )
    field = models.ForeignKey(
        PollCharField,
        on_delete=models.CASCADE,
        related_name='char_field_answers',
        related_query_name='char_field_answer'
    )

    class Meta:
        unique_together = ('response', 'field')

    def __str__(self):
        return self.answer[:30]


class PollTextFieldAnswer(models.Model):
    answer = models.TextField('Answer')
    response = models.ForeignKey(
        PollResponse,
        on_delete=models.CASCADE,
        null=True
    )
    field = models.ForeignKey(
        PollTextField,
        on_delete=models.CASCADE,
        related_name='text_field_answers',
        related_query_name='text_field_answer'
    )

    class Meta:
        unique_together = ('response', 'field')

    def __str__(self):
        return self.answer[:30]


class PollChoiceFieldAnswer(models.Model):
    selected_choice = models.CharField('Selected Choice', max_length=100)
    response = models.ForeignKey(
        PollResponse,
        on_delete=models.CASCADE,
        null=True
    )
    field = models.ForeignKey(
        PollChoiceField,
        on_delete=models.CASCADE,
        related_name='choice_field_answers',
        related_query_name='choice_field_answer'
    )

    class Meta:
        unique_together = ('response', 'field')

    def save(self, *args, **kwargs):
        if self.selected_choice not in self.field.choices:
            return

        super().save(*args, **kwargs)

    def __str__(self):
        return self.selected_choice[:30]


class PollMultiChoiceFieldAnswer(models.Model):
    selected_choices = ArrayField(
        models.CharField('Selected Choices', max_length=100)
    )
    response = models.ForeignKey(
        PollResponse,
        on_delete=models.CASCADE,
        null=True
    )
    field = models.ForeignKey(
        PollMultiChoiceField,
        on_delete=models.CASCADE,
        related_name='multichoice_field_answers',
        related_query_name='multichoice_field_answer'
    )

    class Meta:
        unique_together = ('response', 'field')

    def save(self, *args, **kwargs):
        for choice in self.selected_choices:
            if choice not in self.field.choices:
                return

        super().save(*args, **kwargs)
