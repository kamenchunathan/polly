-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module PollApi.Object.AddPollChoiceFieldPayload exposing (..)

import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode
import PollApi.InputObject
import PollApi.Interface
import PollApi.Object
import PollApi.Scalar
import PollApi.ScalarCodecs
import PollApi.Union


pollChoiceField :
    SelectionSet decodesTo PollApi.Object.PollChoiceField
    -> SelectionSet (Maybe decodesTo) PollApi.Object.AddPollChoiceFieldPayload
pollChoiceField object____ =
    Object.selectionForCompositeField "pollChoiceField" [] object____ (Basics.identity >> Decode.nullable)


errors :
    SelectionSet decodesTo PollApi.Object.ErrorType
    -> SelectionSet (List decodesTo) PollApi.Object.AddPollChoiceFieldPayload
errors object____ =
    Object.selectionForCompositeField "errors" [] object____ (Basics.identity >> Decode.list)


clientMutationId : SelectionSet (Maybe String) PollApi.Object.AddPollChoiceFieldPayload
clientMutationId =
    Object.selectionForField "(Maybe String)" "clientMutationId" [] (Decode.string |> Decode.nullable)