import graphene
from graphene_django import DjangoObjectType
from polls.models import (
    Poll as PollModel,
    PollCharField as PollCharFieldModel,
    PollCharFieldAnswer as PollCharFieldAnswerModel,
    PollChoiceField as PollChoiceFieldModel,
    PollChoiceFieldAnswer as PollChoiceFieldAnswerModel,
    PollMultiChoiceField as PollMultiChoiceFieldModel,
    PollMultiChoiceFieldAnswer as PollMultiChoiceFieldAnswerModel,
    PollTextField as PollTextFieldModel,
    PollTextFieldAnswer as PollTextFieldAnswerModel
)
from ..accounts.types import User


class PollCharField(DjangoObjectType):
    class Meta:
        model = PollCharFieldModel
        exclude = ('poll',)


class PollCharFieldAnswer(DjangoObjectType):
    class Meta:
        model = PollCharFieldAnswerModel
        fields = '__all__'


class PollTextField(DjangoObjectType):
    class Meta:
        model = PollTextFieldModel
        exclude = ('poll',)


class PollTextFieldAnswer(DjangoObjectType):
    class Meta:
        model = PollTextFieldAnswerModel
        exclude = ('field',)


class PollChoiceField(DjangoObjectType):
    class Meta:
        model = PollChoiceFieldModel
        exclude = ('poll',)


class PollChoiceFieldAnswer(DjangoObjectType):
    class Meta:
        model = PollChoiceFieldAnswerModel
        exclude = ('field',)


class PollMultiChoiceField(DjangoObjectType):
    class Meta:
        model = PollMultiChoiceFieldModel
        exclude = ('poll',)


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


class Poll(DjangoObjectType):
    # owner = graphene.NonNull(graphene.Field(User))

    class Meta:
        model = PollModel
        fields = ('id', 'title', 'description', 'owner')

    poll_fields = graphene.NonNull(graphene.List(graphene.NonNull(PollField)))

    def resolve_poll_fields(root, info, **kwargs) -> list[PollField]:
        return [
            *PollCharFieldModel.objects.filter(poll=root),
            *PollTextFieldModel.objects.filter(poll=root),
            *PollChoiceFieldModel.objects.filter(poll=root),
            *PollMultiChoiceFieldModel.objects.filter(poll=root)
        ]
