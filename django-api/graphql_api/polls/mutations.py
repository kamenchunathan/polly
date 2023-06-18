from typing import Optional
import graphene

from django.conf import settings
from django.contrib.auth import authenticate
from graphene_django.types import ErrorType
from graphene_django.forms.mutation import (
    DjangoFormMutation,
    DjangoModelFormMutation
)

from authentication.models import User as UserModel
from polls.models import (
    Poll as PollModel,
    PollResponse as PollResponseModel,
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
    PollResponse,
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

# TODO(nathan): A lot of repition is present in the perform_mutation function.
#   Come up with a suitable abstraction for this perhaps by creating a
#   superclass for the Answer mutations

class AddPollCharFieldAnswer(DjangoModelFormMutation):
    poll_char_field_answer = graphene.Field(PollCharFieldAnswer)
    errors = graphene.NonNull(graphene.List(graphene.NonNull(ErrorType)))

    class Meta:
        form_class = PollCharFieldAnswerForm
        return_field_name = 'poll_char_field_answer'

    @classmethod
    def perform_mutate(cls, form: PollCharFieldAnswerForm, info):
        user: Optional[UserModel] = authenticate(info.context)
        try:
            if user is None or user.is_anonymous:
                raise Exception("User is not authenticated")

            poll_response, _ = PollResponseModel.objects.get_or_create(
                user=user
            )
            obj, _ = PollCharFieldAnswerModel.objects.get_or_create(
                response=poll_response,
                field=form.cleaned_data.get('field')
            )
            obj.answer = form.cleaned_data.get('answer')
            obj.save()
            return AddPollCharFieldAnswer(
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
                         }]
            )


class AddPollChoiceFieldAnswer(DjangoModelFormMutation):
    poll_choice_field_answer = graphene.Field(PollChoiceFieldAnswer)
    errors = graphene.NonNull(graphene.List(graphene.NonNull(ErrorType)))

    class Meta:
        form_class = PollChoiceFieldAnswerForm
        return_field_name = 'poll_choice_field_answer'

    @classmethod
    def perform_mutate(cls, form, info):
        user: Optional[UserModel] = authenticate(info.context)
        try:
            if user is None or user.is_anonymous:
                raise Exception("User is not authenticated")

            poll_response, _ = PollResponseModel.objects.get_or_create(
                user=user
            )
            res = PollChoiceFieldAnswerModel.objects.filter(
                response=poll_response,
                field=form.cleaned_data.get('field')
            )

            obj = None
            if len(res) > 0:
                obj = res[0]
                obj.selected_choice = form.cleaned_data.get('selected_choice')
                obj.save()
            else:
                obj = PollChoiceFieldAnswerModel.objects.create(
                    user=user,
                    **form.cleaned_data
                )

            return cls(
                errors=[],
                poll_choice_field_answer=obj
            )
        except Exception as e:
            print(e)
            debug_msgs: list[str] = []
            if settings.DEBUG:
                debug_msgs = [
                    str(e)
                ]

            return cls(
                errors=[
                    {'field': 'id',
                     'messages': ['Something went wrong', *debug_msgs]
                     }
                ]
            )


class AddPollTextFieldAnswer(DjangoModelFormMutation):
    poll_text_field_answer = graphene.Field(PollTextFieldAnswer)
    errors = graphene.NonNull(graphene.List(graphene.NonNull(ErrorType)))

    class Meta:
        form_class = PollTextFieldAnswerForm
        return_field_name = 'poll_text_field_answer'

    @classmethod
    def perform_mutate(cls, form, info):
        user: Optional[UserModel] = authenticate(info.context)
        try:
            if user is None or user.is_anonymous:
                raise Exception("User is not authenticated")
            poll_response, _ = PollResponseModel.objects.get_or_create(
                user=user
            )
            obj, created = PollTextFieldAnswerModel.objects.get_or_create(
                response=poll_response,
                field=form.cleaned_data.get('field')
            )
            if not created:
                obj.answer = form.cleaned_data.get('answer')
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
                         }]
            )


class AddPollMultiChoiceFieldAnswer(DjangoModelFormMutation):
    poll_multi_choice_field_answer = graphene.Field(PollMultiChoiceFieldAnswer)
    errors = graphene.NonNull(graphene.List(graphene.NonNull(ErrorType)))

    class Meta:
        form_class = PollMultiChoiceFieldAnswerForm
        return_field_name = 'poll_multi_choice_field_answer'

    @classmethod
    def perform_mutate(cls, form: PollMultiChoiceFieldAnswerForm, info):
        user: Optional[UserModel] = authenticate(info.context)
        try:
            if user is None or user.is_anonymous:
                raise Exception("User is not authenticated")

            poll_response, _ = PollResponseModel.objects.get_or_create(
                user=user
            )
            qs = PollMultiChoiceFieldAnswerModel.objects.filter(
                response=poll_response,
                field=form.cleaned_data.get('field')
            )

            obj = None
            if len(qs) > 0:
                obj = qs[0]
                obj.selected_choices = form.cleaned_data.get(
                    'selected_choices'
                )
                obj.save()
            else:
                obj = PollMultiChoiceFieldAnswerModel.objects.create(
                    user=user,
                    **form.cleaned_data
                )
            return cls(
                errors=[],
                poll_multi_choice_field_answer=obj
            )

        except Exception as e:
            print(e)
            debug_msgs: list[str] = []
            if settings.DEBUG:
                debug_msgs = [
                    str(e)
                ]

            return cls(
                errors=[
                    {'field': 'id',
                     'messages': ['Something went wrong', *debug_msgs]
                     }
                ]
            )
