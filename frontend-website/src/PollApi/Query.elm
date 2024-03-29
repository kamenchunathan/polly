-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module PollApi.Query exposing (..)

import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode exposing (Decoder)
import PollApi.InputObject
import PollApi.Interface
import PollApi.Object
import PollApi.Scalar
import PollApi.ScalarCodecs
import PollApi.Union


hello : SelectionSet String RootQuery
hello =
    Object.selectionForField "String" "hello" [] Decode.string


type alias PollRequiredArguments =
    { pollId : PollApi.ScalarCodecs.Id }


poll :
    PollRequiredArguments
    -> SelectionSet decodesTo PollApi.Object.Poll
    -> SelectionSet (Maybe decodesTo) RootQuery
poll requiredArgs____ object____ =
    Object.selectionForCompositeField "poll" [ Argument.required "pollId" requiredArgs____.pollId (PollApi.ScalarCodecs.codecs |> PollApi.Scalar.unwrapEncoder .codecId) ] object____ (Basics.identity >> Decode.nullable)
