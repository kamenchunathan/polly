module PollSelectionSets exposing
    ( AddCharFieldAnswerPayload
    , answerMutation
    , charFieldAnswerMutation
    , choiceFieldAnswerMutation
    , multiChoiceFieldAnswerMutation
    , multipleAnswers
    , specificPoll
    , textFieldAnswerMutation
    )

import Data.Poll exposing (Field(..), Poll)
import Dict exposing (Dict)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import PollApi.InputObject exposing (buildAddPollCharFieldAnswerInput)
import PollApi.Mutation exposing (addPollCharFieldAnswer)
import PollApi.Object exposing (AddPollCharFieldAnswerPayload, PollCharFieldAnswer)
import PollApi.Object.AddPollCharFieldAnswerPayload as AddPollCharFieldAnswerPayload
import PollApi.Object.ErrorType as ErrorType
import PollApi.Object.Poll as Poll
import PollApi.Object.PollCharField as PollCharField
import PollApi.Object.PollCharFieldAnswer as PollCharFieldAnswer
import PollApi.Object.PollChoiceField as PollChoiceField
import PollApi.Object.PollMultiChoiceField as PollMultiChoiceField
import PollApi.Object.PollTextField as PollTextField
import PollApi.Query exposing (poll)
import PollApi.Scalar exposing (Id(..))
import PollApi.Union.PollField exposing (Fragments, fragments)


type alias ApiError =
    { field : String
    , messages : List String
    }


type alias AnswerPayload =
    { id : String
    , answer : String
    }


type alias AddCharFieldAnswerPayload =
    { mutationId : Maybe String
    , answerPayload : Maybe AnswerPayload
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


charFieldAnswer : SelectionSet AnswerPayload PollCharFieldAnswer
charFieldAnswer =
    let
        makeAnswerPayload (Id fieldId) =
            AnswerPayload fieldId
    in
    SelectionSet.map2 makeAnswerPayload
        PollCharFieldAnswer.id
        PollCharFieldAnswer.answer



------------------------------------------------------------------------------------------------------------
--------------------------------------------- MUTATIONS ----------------------------------------------------
------------------------------------------------------------------------------------------------------------


addPollCharFieldAnswerPayload : SelectionSet AddCharFieldAnswerPayload AddPollCharFieldAnswerPayload
addPollCharFieldAnswerPayload =
    SelectionSet.map3
        AddCharFieldAnswerPayload
        AddPollCharFieldAnswerPayload.clientMutationId
        (AddPollCharFieldAnswerPayload.pollCharFieldAnswer charFieldAnswer)
        (AddPollCharFieldAnswerPayload.errors (SelectionSet.map2 ApiError ErrorType.field ErrorType.messages))


multipleAnswers : SelectionSet (Dict String (Maybe AddCharFieldAnswerPayload)) Graphql.Operation.RootMutation
multipleAnswers =
    SelectionSet.dict
        [ ( "wow", answerMutation )
        ]


answerMutation : SelectionSet (Maybe AddCharFieldAnswerPayload) Graphql.Operation.RootMutation
answerMutation =
    --TODO(nathan): take arguments to make an actual mutation
    addPollCharFieldAnswer
        { input =
            buildAddPollCharFieldAnswerInput
                { answer = "I'm not really sure but I'm also not too smart"
                , field = Id "38"
                }
                identity
        }
        addPollCharFieldAnswerPayload


choiceFieldAnswerMutation :
    PollApi.InputObject.AddPollCharFieldAnswerInputRequiredFields
    -> SelectionSet (Maybe AddCharFieldAnswerPayload) Graphql.Operation.RootMutation
choiceFieldAnswerMutation requiredCharfields =
    addPollCharFieldAnswer
        { input = buildAddPollCharFieldAnswerInput requiredCharfields identity }
        addPollCharFieldAnswerPayload


textFieldAnswerMutation : PollApi.InputObject.AddPollCharFieldAnswerInputRequiredFields -> SelectionSet (Maybe AddCharFieldAnswerPayload) Graphql.Operation.RootMutation
textFieldAnswerMutation requiredCharfields =
    addPollCharFieldAnswer
        { input = buildAddPollCharFieldAnswerInput requiredCharfields identity }
        addPollCharFieldAnswerPayload


multiChoiceFieldAnswerMutation : PollApi.InputObject.AddPollCharFieldAnswerInputRequiredFields -> SelectionSet (Maybe AddCharFieldAnswerPayload) Graphql.Operation.RootMutation
multiChoiceFieldAnswerMutation requiredCharfields =
    addPollCharFieldAnswer
        { input = buildAddPollCharFieldAnswerInput requiredCharfields identity }
        addPollCharFieldAnswerPayload


charFieldAnswerMutation : PollApi.InputObject.AddPollCharFieldAnswerInputRequiredFields -> SelectionSet (Maybe AddCharFieldAnswerPayload) Graphql.Operation.RootMutation
charFieldAnswerMutation requiredCharfields =
    addPollCharFieldAnswer
        { input = buildAddPollCharFieldAnswerInput requiredCharfields identity }
        addPollCharFieldAnswerPayload
