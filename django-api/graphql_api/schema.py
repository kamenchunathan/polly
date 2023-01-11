from typing import Iterable
import graphene
from graphene_django import DjangoObjectType
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

from authentication.models import User as UserModel

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
        model =PollTextFieldModel
        exclude = ('poll',)


class PollTextFieldAnswer(DjangoObjectType):
    class Meta:
        model =PollTextFieldAnswerModel
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
        types = (PollCharField, PollTextField, PollChoiceField, PollMultiChoiceField)
    

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

schema = graphene.Schema(query=RootQuery)
