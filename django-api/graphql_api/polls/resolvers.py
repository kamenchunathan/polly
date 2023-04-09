from polls.models import Poll as PollModel


def resolve_single_poll(pollId: int):
    res = PollModel.objects.filter(id=pollId)
    if len(res) > 0:
        return res[0]
    return
