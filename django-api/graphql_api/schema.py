from typing import Iterable

import graphene
from django.conf import settings
from graphene_django import DjangoObjectType
from graphene_django.forms.mutation import DjangoModelFormMutation, DjangoFormMutation
from graphene_django.types import ErrorType

from authentication.models import User as UserModel
from polls.forms import (
    PollCharFieldForm,
    PollTextFieldForm,
    PollChoiceFieldForm,
    PollMultiChoiceFieldForm,
    PollCharFieldAnswerForm,
    PollTextFieldAnswerForm,
    PollChoiceFieldAnswerForm,
    PollMultiChoiceFieldAnswerForm
)
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


# -------------------------------- QUERIES -------------------------------


class User(DjangoObjectType):
    class Meta:
        model = UserModel
        fields = ('id', 'username')


class PollCharField(DjangoObjectType):
    class Meta:
        model = PollCharFieldModel
        exclude = ('poll',)


class PollCharFieldAnswer(DjangoObjectType):
    class Meta:
        model = PollCharFieldAnswerModel
        exclude = ('field',)


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
        types = (PollCharField,
                 PollTextField,
                 PollChoiceField,
                 PollMultiChoiceField)


class Poll(DjangoObjectType):
    class Meta:
        model = PollModel
        fields = ('id', 'title', 'description')

    poll_fields = graphene.NonNull(graphene.List(graphene.NonNull(PollField)))

    def resolve_poll_fields(root, info, **kwargs) -> Iterable[PollField]:
        return [
            *PollCharFieldModel.objects.filter(poll=root),
            *PollTextFieldModel.objects.filter(poll=root),
            *PollChoiceFieldModel.objects.filter(poll=root),
            *PollMultiChoiceFieldModel.objects.filter(poll=root)
        ]


class RootQuery(graphene.ObjectType):
    hello = graphene.String(required=True)
    polls = graphene.NonNull(graphene.List(graphene.NonNull(Poll)))
    poll = graphene.Field(Poll, pollId=graphene.ID(required=True))

    def resolve_hello(root, info, **kwargs):
        return 'Hujambo mkuu'

    def resolve_polls(root, info, **kwargs):
        return PollModel.objects.all()

    def resolve_poll(root, info, pollId):
        res = PollModel.objects.filter(id=pollId)
        if len(res) > 0:
            return res[0]

        return


# ----------------------------------------------------------------------------
# -------------------------------- MUTATIONS  --------------------------------
# ----------------------------------------------------------------------------


class CreatePoll(graphene.Mutation):
    class Arguments:
        title = graphene.String(required=True)
        description = graphene.String()

    poll = graphene.Field(Poll)
    errors = graphene.NonNull(graphene.List(graphene.NonNull(ErrorType)))

    @classmethod
    def mutate(cls, root, info, title=None, description=None):
        if description is None:
            description = ''

        poll = PollModel.objects.create(
            title=title,
            owner=info.context.user,
            description=description,
        )
        print(poll)
        return CreatePoll(poll=poll)


class AddPollCharField(DjangoModelFormMutation):
    poll_char_field = graphene.Field(PollCharField)

    class Meta:
        form_class = PollCharFieldForm
        return_field_name = 'poll_char_field'


class AddPollTextField(DjangoModelFormMutation):
    poll_text_field = graphene.Field(PollTextField)

    class Meta:
        form_class = PollTextFieldForm
        return_field_name = 'poll_text_field'


class AddPollChoiceField(DjangoModelFormMutation):
    poll_choice_field = graphene.Field(PollChoiceField)

    class Meta:
        form_class = PollChoiceFieldForm
        return_field_name = 'poll_choice_field'


class AddPollMultiChoiceField(DjangoModelFormMutation):
    poll_multi_choice_field = graphene.Field(PollMultiChoiceField)

    class Meta:
        form_class = PollMultiChoiceFieldForm
        return_field_name = 'poll_multi_choice_field'


class AddPollCharFieldAnswer(DjangoFormMutation):
    poll_char_field_answer = graphene.Field(PollCharFieldAnswer)

    class Meta:
        form_class = PollCharFieldAnswerForm

    @classmethod
    def perform_mutate(cls, form: PollCharFieldAnswerForm, info):
        user: User = info.context.user
        try:
            obj = PollCharFieldAnswerModel.objects.get_or_create(
                user=user,
                field=form.cleaned_data.get('field')
            )
            obj.save()
            return cls(
                errors=[],
                poll_char_field_answer=obj
            )
        except Exception as e:
            debug_msgs: list[str] = []
            if settings.DEBUG:
                debug_msgs = [
                    str(e)
                ]

            return cls(
                errors=[{'field': 'id',
                         'messages': ['Something went wrong', *debug_msgs]
                         }],
                poll_char_field_answer=obj
            )


class AddPollChoiceFieldAnswer(DjangoModelFormMutation):
    poll_choice_field_answer = graphene.Field(PollChoiceFieldAnswer)

    class Meta:
        form_class = PollChoiceFieldAnswerForm
        return_field_name = 'poll_choice_field_answer'


class AddPollTextFieldAnswer(DjangoModelFormMutation):
    poll_text_field_answer = graphene.Field(PollTextFieldAnswer)

    class Meta:
        form_class = PollTextFieldAnswerForm
        return_field_name = 'poll_text_field_answer'


class AddPollMultiChoiceFieldAnswer(DjangoModelFormMutation):
    poll_multi_choice_field_answer = graphene.Field(PollMultiChoiceFieldAnswer)

    class Meta:
        form_class = PollMultiChoiceFieldAnswerForm
        return_field_name = 'poll_multi_choice_field_answer'


class RootMutation(graphene.ObjectType):
    create_poll = CreatePoll.Field()
    add_poll_char_field = AddPollCharField.Field()
    add_poll_text_field = AddPollTextField.Field()
    add_poll_choice_field = AddPollChoiceField.Field()
    add_poll_multi_choice_field = AddPollMultiChoiceField.Field()
    add_poll_char_field_answer = AddPollCharFieldAnswer.Field()
    add_poll_text_field_answer = AddPollTextFieldAnswer.Field()
    add_poll_choice_field_answer = AddPollChoiceFieldAnswer.Field()
    add_poll_multi_choice_field_answer = AddPollMultiChoiceFieldAnswer.Field()


schema = graphene.Schema(query=RootQuery, mutation=RootMutation)
