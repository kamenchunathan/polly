import graphene
from graphene_django.utils import camelize


class GraphqlError(graphene.Scalar):

    @staticmethod
    def serialize(errors):
        print(errors)
        if not isinstance(errors, dict):
            if isinstance(errors, list) and len(errors) == 0:
                errors = {}
            else:
                errors = {'detail': errors}

        if errors.get('__all__', False):
            errors['non_field_errors'] = errors.pop('__all__')

        return camelize(errors)
