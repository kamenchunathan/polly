import graphene

from .polls.schema import PollQuery, PollMutation


class RootQuery(PollQuery):
    pass


class RootMutation(PollMutation):
    pass


schema = graphene.Schema(query=RootQuery, mutation=RootMutation)
