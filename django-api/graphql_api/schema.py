from typing import Iterable

import graphene
from graphene_django import DjangoObjectType
from graphene_django.forms.mutation import DjangoModelFormMutation

from authentication.models import User as UserModel
from polls import models
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
        types = (PollCharField, PollTextField,
                 PollChoiceField, PollMultiChoiceField)


class Poll(DjangoObjectType):
    class Meta:
        model = PollModel
        fields = ('title', 'description')

    poll_fields = graphene.List(PollField)

    def resolve_poll_fields(root, info, **kwargs) -> Iterable[PollField]:
        return [*PollCharFieldModel.objects.filter(poll=root),
                *PollTextFieldModel.objects.filter(poll=root),
                *PollChoiceFieldModel.objects.filter(poll=root),
                *PollMultiChoiceFieldModel.objects.filter(poll=root)
                ]


class RootQuery(graphene.ObjectType):
    hello = graphene.String()
    polls = graphene.List(Poll)

    def resolve_hello(root, info, **kwargs):
        return 'Hello world'

    def resolve_polls(root, info, **kwargs):
        return PollModel.objects.all()

# -------------------------------- MUTATIONS  -------------------------------


class CreatePoll(graphene.Mutation):
    class Arguments:
        title = graphene.String(required=True)
        description = graphene.String()

    poll = graphene.Field(Poll)

    def mutate(root, info, title=None, description=None):
        poll = PollModel.objects.create(title=title, description=description)
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


class AddPollCharFieldAnswer(DjangoModelFormMutation):
    pollcharfieldanswer = graphene.Field(PollCharFieldAnswer)

    class Meta:
        form_class = PollCharFieldAnswerForm


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



class Mutation(graphene.ObjectType):
    create_poll = CreatePoll.Field()
    add_poll_char_field = AddPollCharField.Field()
    add_poll_text_field = AddPollTextField.Field()
    add_poll_choice_field = AddPollChoiceField.Field()
    add_poll_multi_choice_field = AddPollMultiChoiceField.Field()
    add_poll_char_field_answer = AddPollCharFieldAnswer.Field()
    add_poll_text_field_answer = AddPollTextFieldAnswer.Field()
    add_poll_choice_field_answer = AddPollChoiceFieldAnswer.Field()
    add_poll_multi_choice_field_answer = AddPollMultiChoiceFieldAnswer.Field()
 
schema = graphene.Schema(query=RootQuery, mutation=Mutation)
