import graphene 
from graphene_django import DjangoObjectType
from polls.models import Poll


class PollType(DjangoObjectType):
    class Meta:
        model = Poll
        fields = ('title', 'description')


class RootQuery(graphene.ObjectType):
    polls = graphene.List(PollType)

    def resolve_polls(root, info, **kwargs):
        Poll.objects.all()


schema = graphene.Schema(query=RootQuery)
