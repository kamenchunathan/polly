import graphene

from django.conf import settings
from graphene_django.forms.mutation import (
    DjangoModelFormMutation,
    DjangoFormMutation,
    BaseDjangoFormMutation,
    DjangoFormMutationOptions
)
from graphene_django.types import ErrorType

from authentication.models import User as UserModel
from polls.models import (
    Poll as PollModel,
    PollCharField as PollCharFieldModel,
    PollTextField as PollTextFieldModel,
    PollChoiceField as PollChoiceFieldModel,
    PollMultiChoiceField as PollMultiChoiceFieldModel,
    PollCharFieldAnswer as PollCharFieldAnswerModel,
    PollTextFieldAnswer as PollTextFieldAnswerModel,
    PollChoiceFieldAnswer as PollChoiceFieldAnswerModel,
    PollMultiChoiceFieldAnswer as PollMultiChoiceFieldAnswerModel


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

from .types import (
    Poll,
    PollCharField,
    PollCharFieldAnswer,
    PollTextField,
    PollTextFieldAnswer,
    PollChoiceField,
    PollChoiceFieldAnswer,
    PollMultiChoiceField,
    PollMultiChoiceFieldAnswer
)


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


# -----------------------------------------------------------------------------
# ------------------------------- Answers -------------------------------------
# -----------------------------------------------------------------------------


class AddPollCharFieldAnswer(DjangoFormMutation):
    poll_char_field_answer = graphene.Field(PollCharFieldAnswer)

    class Meta:
        form_class = PollCharFieldAnswerForm

    @classmethod
    def perform_mutate(cls, form: PollCharFieldAnswerForm, info):
        user: UserModel = info.context.user
        try:
            obj, _ = PollCharFieldAnswerModel.objects.get_or_create(
                user=user,
                **form.cleaned_data
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


class AddPollChoiceFieldAnswer(DjangoFormMutation):
    poll_choice_field_answer = graphene.Field(PollChoiceFieldAnswer)

    class Meta:
        form_class = PollChoiceFieldAnswerForm

    @classmethod
    def perform_mutate(cls, form, info):
        user: UserModel = info.context.user
        try:
            obj, created = PollChoiceFieldAnswerModel.objects.get_or_create(
                user=user,
                **form.cleaned_data
            )
            if not created:
                obj.save()
            return cls(
                errors=[],
                poll_choice_field_answer=obj
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
                poll_choice_field_answer=obj
            )


class AddPollTextFieldAnswer(DjangoFormMutation):
    poll_text_field_answer = graphene.Field(PollTextFieldAnswer)

    class Meta:
        form_class = PollTextFieldAnswerForm
        return_field_name = 'poll_text_field_answer'

    @classmethod
    def perform_mutate(cls, form, info):
        user: UserModel = info.context.user
        try:
            obj, created = PollTextFieldAnswerModel.objects.get_or_create(
                user=user,
                **form.cleaned_data
            )
            if not created:
                obj.save()
            return cls(
                errors=[],
                poll_text_field_answer=obj
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
                poll_text_field_answer=obj
            )


class AddPollMultiChoiceFieldAnswer(DjangoFormMutation):
    poll_multi_choice_field_answer = graphene.Field(PollMultiChoiceFieldAnswer)

    class Meta:
        form_class = PollMultiChoiceFieldAnswerForm

    @classmethod
    def perform_mutate(cls, form, info):
        user: UserModel = info.context.user
        try:
            obj, _ = PollMultiChoiceFieldAnswerModel.objects.get_or_create(
                user=user,
                **form.cleaned_data
            )
            obj.save()
            return cls(
                errors=[],
                poll_multi_choice_field_answer=obj
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
                poll_multi_choice_field_answer=obj
            )
