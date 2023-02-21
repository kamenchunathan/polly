-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module PollApi.Object.PollChoiceField exposing (..)

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


id : SelectionSet PollApi.ScalarCodecs.Id PollApi.Object.PollChoiceField
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (PollApi.ScalarCodecs.codecs |> PollApi.Scalar.unwrapCodecs |> .codecId |> .decoder)


text : SelectionSet String PollApi.Object.PollChoiceField
text =
    Object.selectionForField "String" "text" [] Decode.string


choices : SelectionSet (List String) PollApi.Object.PollChoiceField
choices =
    Object.selectionForField "(List String)" "choices" [] (Decode.string |> Decode.list)


choiceFieldAnswers :
    SelectionSet decodesTo PollApi.Object.PollChoiceFieldAnswer
    -> SelectionSet (List decodesTo) PollApi.Object.PollChoiceField
choiceFieldAnswers object____ =
    Object.selectionForCompositeField "choiceFieldAnswers" [] object____ (Basics.identity >> Decode.list)