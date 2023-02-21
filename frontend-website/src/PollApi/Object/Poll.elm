-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module PollApi.Object.Poll exposing (..)

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


id : SelectionSet PollApi.ScalarCodecs.Id PollApi.Object.Poll
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (PollApi.ScalarCodecs.codecs |> PollApi.Scalar.unwrapCodecs |> .codecId |> .decoder)


title : SelectionSet String PollApi.Object.Poll
title =
    Object.selectionForField "String" "title" [] Decode.string


description : SelectionSet String PollApi.Object.Poll
description =
    Object.selectionForField "String" "description" [] Decode.string


pollFields :
    SelectionSet decodesTo PollApi.Union.PollField
    -> SelectionSet (List decodesTo) PollApi.Object.Poll
pollFields object____ =
    Object.selectionForCompositeField "pollFields" [] object____ (Basics.identity >> Decode.list)