import graphene
from graphene import NonNull, List, Field
from graphene_django import DjangoObjectType
from polls.models import (
    Poll as PollModel,
    PollResponse as PollResponseModel,
    PollCharField as PollCharFieldModel,
    PollCharFieldAnswer as PollCharFieldAnswerModel,
    PollChoiceField as PollChoiceFieldModel,
    PollChoiceFieldAnswer as PollChoiceFieldAnswerModel,
    PollMultiChoiceField as PollMultiChoiceFieldModel,
    PollMultiChoiceFieldAnswer as PollMultiChoiceFieldAnswerModel,
    PollTextField as PollTextFieldModel,
    PollTextFieldAnswer as PollTextFieldAnswerModel
)
from django.contrib.auth import get_user_model

User = get_user_model()


class PollCharField(DjangoObjectType):
    class Meta:
        model = PollCharFieldModel
        exclude = ('poll', 'char_field_answers')


class PollCharFieldAnswer(DjangoObjectType):
    class Meta:
        model = PollCharFieldAnswerModel
        fields = '__all__'


class PollTextField(DjangoObjectType):
    class Meta:
        model = PollTextFieldModel
        exclude = ('poll', 'text_field_answers')


class PollTextFieldAnswer(DjangoObjectType):
    class Meta:
        model = PollTextFieldAnswerModel
        exclude = ('field',)


class PollChoiceField(DjangoObjectType):
    class Meta:
        model = PollChoiceFieldModel
        exclude = ('poll', 'choice_field_answers')


class PollChoiceFieldAnswer(DjangoObjectType):
    class Meta:
        model = PollChoiceFieldAnswerModel
        exclude = ('field',)


class PollMultiChoiceField(DjangoObjectType):
    class Meta:
        model = PollMultiChoiceFieldModel
        exclude = ('poll', 'multichoice_field_answers')


class PollMultiChoiceFieldAnswer(DjangoObjectType):
    class Meta:
        model = PollMultiChoiceFieldAnswerModel
        exclude = ('field',)


class PollField(graphene.Union):
    class Meta:
        types = (
            PollCharField,
            PollTextField,
            PollChoiceField,
            PollMultiChoiceField
        )


class PollResponse(DjangoObjectType):
    class Meta:
        model = PollResponseModel


class Poll(DjangoObjectType):
    # owner = NonNull(Field(User))
    # response = Field(PollResponse)
    # responses = NonNull(List(NonNull(Field(PollResponse))))
    poll_fields = NonNull(List(NonNull(PollField)))

    class Meta:
        model = PollModel
        fields = ('id', 'title', 'description', 'owner')

    def resolve_poll_fields(root, info, **kwargs) -> list[PollField]:
        return [
            *PollCharFieldModel.objects.filter(poll=root),
            *PollTextFieldModel.objects.filter(poll=root),
            *PollChoiceFieldModel.objects.filter(poll=root),
            *PollMultiChoiceFieldModel.objects.filter(poll=root)
        ]
