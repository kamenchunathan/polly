-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module PollApi.Object.PollCharFieldAnswer exposing (..)

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


id : SelectionSet PollApi.ScalarCodecs.Id PollApi.Object.PollCharFieldAnswer
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (PollApi.ScalarCodecs.codecs |> PollApi.Scalar.unwrapCodecs |> .codecId |> .decoder)


answer : SelectionSet String PollApi.Object.PollCharFieldAnswer
answer =
    Object.selectionForField "String" "answer" [] Decode.string


user :
    SelectionSet decodesTo PollApi.Object.User
    -> SelectionSet decodesTo PollApi.Object.PollCharFieldAnswer
user object____ =
    Object.selectionForCompositeField "user" [] object____ Basics.identity
