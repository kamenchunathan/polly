from django.db import models
from django.contrib.postgres.fields import ArrayField


class Poll(models.Model):
    title = models.CharField('Poll title', max_length=100)
    description = models.CharField( 'Description', max_length=255, blank=True)


class PollCharField(models.Model):
    question_text = models.CharField( 'Question Text', max_length=100)
    answer = models.CharField( 'Answer', max_length=100, blank=True)
    poll = models.ForeignKey( Poll, on_delete=models.CASCADE)

    def answered(self) -> bool:
        return self.answer == ''


class PollTextField(models.Model):
    question_text = models.CharField( 'Question Text', max_length=100)
    answer = models.TextField('Answer', blank=True)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def answered(self) -> bool:
        return self.answer ==''


class PollChoiceField(models.Model):
    question_text = models.CharField( 'Question Text', max_length=100)
    choices = ArrayField( models.CharField('Choice', max_length=100))
    selected_choice = models.CharField('Selected Choice', max_length=100, blank=True)
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def save(self, *args, **kwargs):
        if self.selected_choice != '' and self.selected_choice not in self.choices:
            return
        
        super().save(*args, **kwargs)


class PollMultiChoiceField(models.Model):
    question_text = models.CharField( 'Question Text', max_length=100)
    choices = ArrayField( models.CharField('Choice', max_length=100))
    selected_choices = ArrayField(models.CharField('Selected Choices', max_length=100))
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE)

    def save(self, *args, **kwargs):
        for choice in self.selected_choices:
            if choice not in self.choices:
                return
        
        super().save(*args, **kwargs)
