import graphene
from .types import Poll
from .resolvers import resolve_single_poll
from .mutations import (
    CreatePoll,
    AddPollCharField,
    AddPollCharFieldAnswer,
    AddPollTextField,
    AddPollTextFieldAnswer,
    AddPollChoiceField,
    AddPollChoiceFieldAnswer,
    AddPollMultiChoiceField,
    AddPollMultiChoiceFieldAnswer
)


class PollQuery(graphene.ObjectType):
    hello = graphene.String(required=True)
    poll = graphene.Field(Poll, pollId=graphene.ID(required=True))

    def resolve_hello(root, info, **kwargs):
        return 'Hujambo mkuu'

    def resolve_poll(root, info, pollId):
        return resolve_single_poll(pollId)


class PollMutation(graphene.ObjectType):
    create_poll = CreatePoll.Field()
    add_poll_char_field = AddPollCharField.Field()
    add_poll_text_field = AddPollTextField.Field()
    add_poll_choice_field = AddPollChoiceField.Field()
    add_poll_multi_choice_field = AddPollMultiChoiceField.Field()
    add_poll_char_field_answer = AddPollCharFieldAnswer.Field()
    add_poll_text_field_answer = AddPollTextFieldAnswer.Field()
    add_poll_choice_field_answer = AddPollChoiceFieldAnswer.Field()
    add_poll_multi_choice_field_answer = AddPollMultiChoiceFieldAnswer.Field()
