-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module PollApi.Mutation exposing (..)

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


type alias CreatePollOptionalArguments =
    { description : OptionalArgument String }


type alias CreatePollRequiredArguments =
    { title : String }


createPoll :
    (CreatePollOptionalArguments -> CreatePollOptionalArguments)
    -> CreatePollRequiredArguments
    -> SelectionSet decodesTo PollApi.Object.CreatePoll
    -> SelectionSet (Maybe decodesTo) RootMutation
createPoll fillInOptionals____ requiredArgs____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { description = Absent }

        optionalArgs____ =
            [ Argument.optional "description" filledInOptionals____.description Encode.string ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "createPoll" (optionalArgs____ ++ [ Argument.required "title" requiredArgs____.title Encode.string ]) object____ (Basics.identity >> Decode.nullable)


type alias AddPollCharFieldRequiredArguments =
    { input : PollApi.InputObject.AddPollCharFieldInput }


addPollCharField :
    AddPollCharFieldRequiredArguments
    -> SelectionSet decodesTo PollApi.Object.AddPollCharFieldPayload
    -> SelectionSet (Maybe decodesTo) RootMutation
addPollCharField requiredArgs____ object____ =
    Object.selectionForCompositeField "addPollCharField" [ Argument.required "input" requiredArgs____.input PollApi.InputObject.encodeAddPollCharFieldInput ] object____ (Basics.identity >> Decode.nullable)


type alias AddPollTextFieldRequiredArguments =
    { input : PollApi.InputObject.AddPollTextFieldInput }


addPollTextField :
    AddPollTextFieldRequiredArguments
    -> SelectionSet decodesTo PollApi.Object.AddPollTextFieldPayload
    -> SelectionSet (Maybe decodesTo) RootMutation
addPollTextField requiredArgs____ object____ =
    Object.selectionForCompositeField "addPollTextField" [ Argument.required "input" requiredArgs____.input PollApi.InputObject.encodeAddPollTextFieldInput ] object____ (Basics.identity >> Decode.nullable)


type alias AddPollChoiceFieldRequiredArguments =
    { input : PollApi.InputObject.AddPollChoiceFieldInput }


addPollChoiceField :
    AddPollChoiceFieldRequiredArguments
    -> SelectionSet decodesTo PollApi.Object.AddPollChoiceFieldPayload
    -> SelectionSet (Maybe decodesTo) RootMutation
addPollChoiceField requiredArgs____ object____ =
    Object.selectionForCompositeField "addPollChoiceField" [ Argument.required "input" requiredArgs____.input PollApi.InputObject.encodeAddPollChoiceFieldInput ] object____ (Basics.identity >> Decode.nullable)


type alias AddPollMultiChoiceFieldRequiredArguments =
    { input : PollApi.InputObject.AddPollMultiChoiceFieldInput }


addPollMultiChoiceField :
    AddPollMultiChoiceFieldRequiredArguments
    -> SelectionSet decodesTo PollApi.Object.AddPollMultiChoiceFieldPayload
    -> SelectionSet (Maybe decodesTo) RootMutation
addPollMultiChoiceField requiredArgs____ object____ =
    Object.selectionForCompositeField "addPollMultiChoiceField" [ Argument.required "input" requiredArgs____.input PollApi.InputObject.encodeAddPollMultiChoiceFieldInput ] object____ (Basics.identity >> Decode.nullable)


type alias AddPollCharFieldAnswerRequiredArguments =
    { input : PollApi.InputObject.AddPollCharFieldAnswerInput }


addPollCharFieldAnswer :
    AddPollCharFieldAnswerRequiredArguments
    -> SelectionSet decodesTo PollApi.Object.AddPollCharFieldAnswerPayload
    -> SelectionSet (Maybe decodesTo) RootMutation
addPollCharFieldAnswer requiredArgs____ object____ =
    Object.selectionForCompositeField "addPollCharFieldAnswer" [ Argument.required "input" requiredArgs____.input PollApi.InputObject.encodeAddPollCharFieldAnswerInput ] object____ (Basics.identity >> Decode.nullable)


type alias AddPollTextFieldAnswerRequiredArguments =
    { input : PollApi.InputObject.AddPollTextFieldAnswerInput }


addPollTextFieldAnswer :
    AddPollTextFieldAnswerRequiredArguments
    -> SelectionSet decodesTo PollApi.Object.AddPollTextFieldAnswerPayload
    -> SelectionSet (Maybe decodesTo) RootMutation
addPollTextFieldAnswer requiredArgs____ object____ =
    Object.selectionForCompositeField "addPollTextFieldAnswer" [ Argument.required "input" requiredArgs____.input PollApi.InputObject.encodeAddPollTextFieldAnswerInput ] object____ (Basics.identity >> Decode.nullable)


type alias AddPollChoiceFieldAnswerRequiredArguments =
    { input : PollApi.InputObject.AddPollChoiceFieldAnswerInput }


addPollChoiceFieldAnswer :
    AddPollChoiceFieldAnswerRequiredArguments
    -> SelectionSet decodesTo PollApi.Object.AddPollChoiceFieldAnswerPayload
    -> SelectionSet (Maybe decodesTo) RootMutation
addPollChoiceFieldAnswer requiredArgs____ object____ =
    Object.selectionForCompositeField "addPollChoiceFieldAnswer" [ Argument.required "input" requiredArgs____.input PollApi.InputObject.encodeAddPollChoiceFieldAnswerInput ] object____ (Basics.identity >> Decode.nullable)


type alias AddPollMultiChoiceFieldAnswerRequiredArguments =
    { input : PollApi.InputObject.AddPollMultiChoiceFieldAnswerInput }


addPollMultiChoiceFieldAnswer :
    AddPollMultiChoiceFieldAnswerRequiredArguments
    -> SelectionSet decodesTo PollApi.Object.AddPollMultiChoiceFieldAnswerPayload
    -> SelectionSet (Maybe decodesTo) RootMutation
addPollMultiChoiceFieldAnswer requiredArgs____ object____ =
    Object.selectionForCompositeField "addPollMultiChoiceFieldAnswer" [ Argument.required "input" requiredArgs____.input PollApi.InputObject.encodeAddPollMultiChoiceFieldAnswerInput ] object____ (Basics.identity >> Decode.nullable)
