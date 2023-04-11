module PollSelectionSets exposing
    ( AnswerPayload
    , answerMutation
    , answerPoll
    , charFieldAnswerMutation
    , choiceFieldAnswerMutation
    , multiChoiceFieldAnswerMutation
    , specificPoll
    , textFieldAnswerMutation
    )

import Data.Poll exposing (Field(..), Poll)
import Dict exposing (Dict)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import PollApi.InputObject exposing (buildAddPollCharFieldAnswerInput, buildAddPollChoiceFieldAnswerInput, buildAddPollMultiChoiceFieldAnswerInput, buildAddPollTextFieldAnswerInput)
import PollApi.Mutation
    exposing
        ( addPollCharFieldAnswer
        , addPollChoiceFieldAnswer
        , addPollMultiChoiceFieldAnswer
        , addPollTextFieldAnswer
        )
import PollApi.Object exposing (PollChoiceFieldAnswer(..))
import PollApi.Object.AddPollCharFieldAnswerPayload as AddPollCharFieldAnswerPayload
import PollApi.Object.AddPollChoiceFieldAnswerPayload as AddPollChoiceFieldAnswerPayload
import PollApi.Object.AddPollMultiChoiceFieldAnswerPayload as AddPollMultiChoiceFieldAnswerPayload
import PollApi.Object.AddPollTextFieldAnswerPayload as AddPollTextFieldAnswerPayload
import PollApi.Object.ErrorType as ErrorType
import PollApi.Object.Poll as Poll
import PollApi.Object.PollCharField as PollCharField
import PollApi.Object.PollCharFieldAnswer as PollCharFieldAnswer
import PollApi.Object.PollChoiceField as PollChoiceField
import PollApi.Object.PollChoiceFieldAnswer as PollChoiceFieldAnswer
import PollApi.Object.PollMultiChoiceField as PollMultiChoiceField
import PollApi.Object.PollMultiChoiceFieldAnswer as PollMultiChoiceFieldAnswer
import PollApi.Object.PollTextField as PollTextField
import PollApi.Object.PollTextFieldAnswer as PollTextFieldAnswer
import PollApi.Query exposing (poll)
import PollApi.Scalar exposing (Id(..))
import PollApi.Union.PollField exposing (Fragments, fragments)


type alias ApiError =
    { field : String
    , messages : List String
    }


type alias AnswerPayload =
    { clientMutationId : Maybe String
    , answerId : Maybe String
    , errors : List ApiError
    }



------------------------------------------------------------------------------------------------------------
----------------------------------------------- Queries ----------------------------------------------------
------------------------------------------------------------------------------------------------------------


specificPoll : Id -> SelectionSet (Maybe Poll) RootQuery
specificPoll pollId =
    Poll.pollFields (fragments charFieldFragments)
        |> SelectionSet.map4 makePoll Poll.id Poll.title Poll.description
        |> poll { pollId = pollId }


makePoll : Id -> String -> String -> List Field -> Poll
makePoll (Id pollId) =
    Poll pollId


charFieldFragments : Fragments Field
charFieldFragments =
    { onPollCharField =
        SelectionSet.map2
            (\(Id fieldId) text ->
                CharField
                    { id = fieldId
                    , questionText = text
                    , answer = Nothing
                    }
            )
            PollCharField.id
            PollCharField.text
    , onPollTextField =
        SelectionSet.map2
            (\(Id fieldId) text ->
                TextField
                    { id = fieldId
                    , questionText = text
                    , answer = Nothing
                    }
            )
            PollTextField.id
            PollTextField.text
    , onPollChoiceField =
        SelectionSet.map3
            (\(Id fieldId) text choices ->
                ChoiceField
                    { id = fieldId
                    , questionText = text
                    , choices = choices
                    , selectedChoice = Nothing
                    }
            )
            PollChoiceField.id
            PollChoiceField.text
            PollChoiceField.choices
    , onPollMultiChoiceField =
        SelectionSet.map3
            (\(Id fieldId) text choices ->
                MultiChoiceField
                    { id = fieldId
                    , questionText = text
                    , choices = choices
                    , selectedChoices = []
                    }
            )
            PollMultiChoiceField.id
            PollMultiChoiceField.text
            PollMultiChoiceField.choices
    }



------------------------------------------------------------------------------------------------------------
--------------------------------------------- MUTATIONS ----------------------------------------------------
------------------------------------------------------------------------------------------------------------


mkAnswerPayload : Maybe String -> Maybe Id -> List ApiError -> AnswerPayload
mkAnswerPayload clientMutationId ansId errors =
    AnswerPayload clientMutationId (Maybe.map (\(Id id) -> id) ansId) errors


addPollCharFieldAnswerPayload : SelectionSet AnswerPayload PollApi.Object.AddPollCharFieldAnswerPayload
addPollCharFieldAnswerPayload =
    SelectionSet.map3
        mkAnswerPayload
        AddPollCharFieldAnswerPayload.clientMutationId
        (AddPollCharFieldAnswerPayload.pollCharFieldAnswer PollCharFieldAnswer.id)
        (AddPollCharFieldAnswerPayload.errors (SelectionSet.map2 ApiError ErrorType.field ErrorType.messages))


addPollTextFieldAnswerPayload : SelectionSet AnswerPayload PollApi.Object.AddPollTextFieldAnswerPayload
addPollTextFieldAnswerPayload =
    SelectionSet.map3
        mkAnswerPayload
        AddPollTextFieldAnswerPayload.clientMutationId
        (AddPollTextFieldAnswerPayload.pollTextFieldAnswer PollTextFieldAnswer.id)
        (AddPollTextFieldAnswerPayload.errors (SelectionSet.map2 ApiError ErrorType.field ErrorType.messages))


addPollChoiceFieldAnswerPayload : SelectionSet AnswerPayload PollApi.Object.AddPollChoiceFieldAnswerPayload
addPollChoiceFieldAnswerPayload =
    SelectionSet.map3
        mkAnswerPayload
        AddPollChoiceFieldAnswerPayload.clientMutationId
        (AddPollChoiceFieldAnswerPayload.pollChoiceFieldAnswer PollChoiceFieldAnswer.id)
        (AddPollChoiceFieldAnswerPayload.errors (SelectionSet.map2 ApiError ErrorType.field ErrorType.messages))


addPollMuliChoiceFieldAnswerPayload : SelectionSet AnswerPayload PollApi.Object.AddPollMultiChoiceFieldAnswerPayload
addPollMuliChoiceFieldAnswerPayload =
    SelectionSet.map3
        mkAnswerPayload
        AddPollMultiChoiceFieldAnswerPayload.clientMutationId
        (AddPollMultiChoiceFieldAnswerPayload.pollMultiChoiceFieldAnswer PollMultiChoiceFieldAnswer.id)
        (AddPollMultiChoiceFieldAnswerPayload.errors (SelectionSet.map2 ApiError ErrorType.field ErrorType.messages))


answerPoll :
    List Field
    -> SelectionSet (Dict String (Maybe AnswerPayload)) Graphql.Operation.RootMutation
answerPoll fields =
    List.map (\field -> ( "wow", answerMutation field )) fields
        |> SelectionSet.dict


answerMutation :
    Field
    -> SelectionSet (Maybe AnswerPayload) Graphql.Operation.RootMutation
answerMutation field =
    case field of
        CharField { id, answer } ->
            charFieldAnswerMutation
                { field = Id id
                , answer = Maybe.withDefault "" answer
                }

        TextField { id, answer } ->
            textFieldAnswerMutation
                { field = Id id
                , answer = Maybe.withDefault "" answer
                }

        ChoiceField { id, selectedChoice } ->
            choiceFieldAnswerMutation
                { field = Id id
                , selectedChoice = Maybe.withDefault "" selectedChoice
                }

        MultiChoiceField { id, selectedChoices } ->
            multiChoiceFieldAnswerMutation
                { field = Id id
                , selectedChoices = String.join "," selectedChoices
                }


charFieldAnswerMutation :
    PollApi.InputObject.AddPollCharFieldAnswerInputRequiredFields
    -> SelectionSet (Maybe AnswerPayload) Graphql.Operation.RootMutation
charFieldAnswerMutation requiredCharfields =
    addPollCharFieldAnswer
        { input = buildAddPollCharFieldAnswerInput requiredCharfields identity }
        addPollCharFieldAnswerPayload


textFieldAnswerMutation :
    PollApi.InputObject.AddPollTextFieldAnswerInputRequiredFields
    -> SelectionSet (Maybe AnswerPayload) Graphql.Operation.RootMutation
textFieldAnswerMutation requiredCharfields =
    addPollTextFieldAnswer
        { input = buildAddPollTextFieldAnswerInput requiredCharfields identity }
        addPollTextFieldAnswerPayload


choiceFieldAnswerMutation :
    PollApi.InputObject.AddPollChoiceFieldAnswerInputRequiredFields
    -> SelectionSet (Maybe AnswerPayload) Graphql.Operation.RootMutation
choiceFieldAnswerMutation requiredCharfields =
    addPollChoiceFieldAnswer
        { input = buildAddPollChoiceFieldAnswerInput requiredCharfields identity }
        addPollChoiceFieldAnswerPayload


multiChoiceFieldAnswerMutation :
    PollApi.InputObject.AddPollMultiChoiceFieldAnswerInputRequiredFields
    -> SelectionSet (Maybe AnswerPayload) Graphql.Operation.RootMutation
multiChoiceFieldAnswerMutation requiredCharfields =
    addPollMultiChoiceFieldAnswer
        { input = buildAddPollMultiChoiceFieldAnswerInput requiredCharfields identity }
        addPollMuliChoiceFieldAnswerPayload
