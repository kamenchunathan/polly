module Pages.Polls.Pollid_ exposing (Model, Msg, page)

import Gen.Params.Polls.Pollid_ exposing (Params)
import Graphql.Http exposing (mutationRequest, queryRequest, send)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Maybe exposing (withDefault)
import Page
import PollApi.InputObject exposing (buildAddPollCharFieldAnswerInput)
import PollApi.Mutation exposing (addPollCharFieldAnswer)
import PollApi.Object exposing (AddPollCharFieldAnswerPayload)
import PollApi.Object.AddPollCharFieldAnswerPayload as AddPollCharFieldAnswerPayload
import PollApi.Object.ErrorType as ErrorType
import PollApi.Object.Poll as Poll
import PollApi.Object.PollCharField as PollCharField
import PollApi.Object.PollCharFieldAnswer as PollCharFieldAnswer
import PollApi.Object.PollChoiceField as PollChoiceField
import PollApi.Object.PollMultiChoiceField as PollMultiChoiceField
import PollApi.Object.PollTextField as PollTextField
import PollApi.Object.User as User
import PollApi.Query exposing (polls)
import PollApi.Scalar exposing (Id(..))
import PollApi.Union.PollField exposing (Fragments, fragments)
import RemoteData exposing (RemoteData(..))
import Request
import Shared
import String exposing (fromInt)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ req_params =
    Page.element
        { init = init req_params
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias User =
    { id : Id
    , username : String
    }


type alias ApiError =
    { field : String
    , messages : List String
    }


type alias AnswerPayload =
    { id : Id
    , answer : String
    , user : User
    }


type alias AddCharFieldAnswerPayload =
    { mutationId : Maybe String
    , answerPayload : Maybe AnswerPayload
    , errors : List ApiError
    }


type
    Field
    -- short text input (<100 characters)
    = CharField
        { id : Id
        , questionText : String
        , answer : Maybe String
        }
      -- long text input
    | TextField
        { id : Id
        , questionText : String
        , answer : Maybe String
        }
      -- choice between a list of options
    | ChoiceField
        { id : Id
        , questionText : String
        , choices : List String
        , selectedChoice : Maybe String
        }
      -- list of selected choices from a set of options
    | MultiChoiceField
        { id : Id
        , questionText : String
        , choices : List String
        , selectedChoices : List String
        }


type alias Poll =
    { id : Id
    , title : String
    , description : String
    , fields : List Field
    }


type alias Model =
    RemoteData String (List Poll)


init : Request.With Params -> ( Model, Cmd Msg )
init { params } =
    let
        _ =
            Debug.log "" params.pollid

        req =
            allPollsSelectionSet
                |> queryRequest "http://localhost:8000/graphql/"
                |> send resultToMessage
    in
    ( NotAsked, req )



-- UPDATE


type Msg
    = GetData
    | NoOpString String
    | GotPolls (List Poll)
    | SetFieldAnswer Id Id String
    | SubmitPoll Id
    | GotAnswer (Maybe AddCharFieldAnswerPayload)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GetData, _ ) ->
            let
                req =
                    allPollsSelectionSet
                        |> queryRequest "http://localhost:8000/graphql/"
                        |> send resultToMessage
            in
            ( model, req )

        -- TODO: remove debug on prod build
        ( NoOpString s, _ ) ->
            -- let
            --     _ =
            --         Debug.log "NoOp" s
            -- in
            ( model, Cmd.none )

        ( GotPolls polls, _ ) ->
            ( Success polls, Cmd.none )

        ( SetFieldAnswer pollId fieldId val, Success polls ) ->
            let
                newPolls =
                    List.map
                        (\poll ->
                            if poll.id == pollId then
                                { poll
                                    | fields =
                                        List.map
                                            (\field ->
                                                if fieldIdMatches fieldId field then
                                                    withAnswerText val field

                                                else
                                                    field
                                            )
                                            poll.fields
                                }

                            else
                                poll
                        )
                        polls
            in
            ( Success newPolls, Cmd.none )

        ( SetFieldAnswer _ _ _, _ ) ->
            ( model, Cmd.none )

        ( SubmitPoll _, _ ) ->
            let
                req =
                    mutationRequest "http://localhost:8000/graphql/" answerMutation
                        |> send payloadResultToMessage
            in
            ( model, req )

        ( GotAnswer a, _ ) ->
            -- let
            --     _ =
            --         Debug.log "answer res" a
            -- in
            ( model, Cmd.none )


payloadResultToMessage : Result (Graphql.Http.Error (Maybe AddCharFieldAnswerPayload)) (Maybe AddCharFieldAnswerPayload) -> Msg
payloadResultToMessage =
    GotAnswer << Result.withDefault Nothing


withAnswerText : String -> Field -> Field
withAnswerText answerText field =
    case field of
        CharField fieldParams ->
            CharField { fieldParams | answer = Just answerText }

        TextField fieldParams ->
            TextField { fieldParams | answer = Just answerText }

        ChoiceField fieldParams ->
            ChoiceField { fieldParams | selectedChoice = Just answerText }

        MultiChoiceField ({ selectedChoices } as fieldParams) ->
            if List.member answerText selectedChoices then
                MultiChoiceField { fieldParams | selectedChoices = List.filter (\x -> x /= answerText) selectedChoices }

            else
                MultiChoiceField { fieldParams | selectedChoices = answerText :: selectedChoices }


fieldIdMatches : Id -> Field -> Bool
fieldIdMatches fieldId field =
    case field of
        CharField { id } ->
            fieldId == (Id <| unwrapId id ++ "_c")

        TextField { id } ->
            fieldId == (Id <| unwrapId id ++ "_t")

        ChoiceField { id } ->
            fieldId == (Id <| unwrapId id ++ "_ch")

        MultiChoiceField { id } ->
            fieldId == (Id <| unwrapId id ++ "_m")


unwrapId : Id -> String
unwrapId (Id inner) =
    inner


allPollsSelectionSet : SelectionSet (List Poll) RootQuery
allPollsSelectionSet =
    Poll.pollFields (fragments charFieldFragments)
        |> SelectionSet.map4 Poll Poll.id Poll.title Poll.description
        |> polls


charFieldFragments : Fragments Field
charFieldFragments =
    { onPollCharField =
        SelectionSet.map2
            (\id text ->
                CharField
                    { id = id
                    , questionText = text
                    , answer = Nothing
                    }
            )
            PollCharField.id
            PollCharField.text
    , onPollTextField =
        SelectionSet.map2
            (\id text ->
                TextField
                    { id = id
                    , questionText = text
                    , answer = Nothing
                    }
            )
            PollTextField.id
            PollTextField.text
    , onPollChoiceField =
        SelectionSet.map3
            (\id text choices ->
                ChoiceField
                    { id = id
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
            (\id text choices ->
                MultiChoiceField
                    { id = id
                    , questionText = text
                    , choices = choices
                    , selectedChoices = []
                    }
            )
            PollMultiChoiceField.id
            PollMultiChoiceField.text
            PollMultiChoiceField.choices
    }


resultToMessage : Result (Graphql.Http.Error (List Poll)) (List Poll) -> Msg
resultToMessage res =
    Result.withDefault [] res
        |> GotPolls


charFieldAnswer : SelectionSet AnswerPayload PollApi.Object.PollCharFieldAnswer
charFieldAnswer =
    SelectionSet.map2 User User.id User.username
        |> PollCharFieldAnswer.user
        |> SelectionSet.map3 AnswerPayload
            PollCharFieldAnswer.id
            PollCharFieldAnswer.answer


addPollCharFieldAnswerPayload : SelectionSet AddCharFieldAnswerPayload AddPollCharFieldAnswerPayload
addPollCharFieldAnswerPayload =
    SelectionSet.map3
        AddCharFieldAnswerPayload
        AddPollCharFieldAnswerPayload.clientMutationId
        (AddPollCharFieldAnswerPayload.pollCharFieldAnswer charFieldAnswer)
        (AddPollCharFieldAnswerPayload.errors (SelectionSet.map2 ApiError ErrorType.field ErrorType.messages))


answerMutation : SelectionSet (Maybe AddCharFieldAnswerPayload) Graphql.Operation.RootMutation
answerMutation =
    addPollCharFieldAnswer
        { input =
            buildAddPollCharFieldAnswerInput
                { answer = "I'm not really sure but I'm also not too smart"
                , user = Id "3"
                , field = Id "38"
                }
                identity
        }
        addPollCharFieldAnswerPayload



-- choiceFieldAnswerMutation :
--     PollApi.InputObject.AddPollCharFieldAnswerInputRequiredFields
--     -> SelectionSet (Maybe AddCharFieldAnswerPayload) Graphql.Operation.RootMutation
-- choiceFieldAnswerMutation requiredCharfields =
--     addPollCharFieldAnswer
--         { input = buildAddPollCharFieldAnswerInput requiredCharfields identity }
--         addPollCharFieldAnswerPayload
--
--
-- textFieldAnswerMutation : PollApi.InputObject.AddPollCharFieldAnswerInputRequiredFields -> SelectionSet (Maybe AddCharFieldAnswerPayload) Graphql.Operation.RootMutation
-- textFieldAnswerMutation requiredCharfields =
--     addPollCharFieldAnswer
--         { input = buildAddPollCharFieldAnswerInput requiredCharfields identity }
--         addPollCharFieldAnswerPayload
--
--
-- multiChoiceFieldAnswerMutation : PollApi.InputObject.AddPollCharFieldAnswerInputRequiredFields -> SelectionSet (Maybe AddCharFieldAnswerPayload) Graphql.Operation.RootMutation
-- multiChoiceFieldAnswerMutation requiredCharfields =
--     addPollCharFieldAnswer
--         { input = buildAddPollCharFieldAnswerInput requiredCharfields identity }
--         addPollCharFieldAnswerPayload
--
--
-- charFieldAnswerMutation : PollApi.InputObject.AddPollCharFieldAnswerInputRequiredFields -> SelectionSet (Maybe AddCharFieldAnswerPayload) Graphql.Operation.RootMutation
-- charFieldAnswerMutation requiredCharfields =
--     addPollCharFieldAnswer
--         { input = buildAddPollCharFieldAnswerInput requiredCharfields identity }
--         addPollCharFieldAnswerPayload
--
--
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Home | Polls"
    , body =
        [ H.div
            [ HA.class "min-h-screen h-full bg-neutral-100" ]
            [ navbar
            , header
            , content model
            ]
        ]
    }


content : Model -> Html Msg
content model =
    case model of
        NotAsked ->
            H.div
                [ HA.class "p-4 w-4/6 mx-auto" ]
                [ H.div [ HA.class "py-8" ]
                    [ H.p [] [ H.text "Something appears to have gone wrong." ]
                    , H.p [] [ H.text "Click the button to refresh the poll" ]
                    ]

                --TODO(nathan): edit button to only get data from the poll in the url
                , refreshDataButton
                ]

        Loading ->
            H.div [] [ H.text "Loading" ]

        Failure failuremessage ->
            H.div [] [ H.text failuremessage ]

        Success polls ->
            viewPolls polls


viewPolls : List Poll -> Html Msg
viewPolls polls =
    H.div
        [ HA.class "p-4 w-4/6 mx-auto" ]
        (List.map viewPoll polls)


viewPoll : Poll -> Html Msg
viewPoll poll =
    H.div
        [ HA.class "p-2 m-2 md:px-4" ]
        [ H.p [ HA.class "text-lg font-medium" ] [ H.text poll.title ]
        , H.p [ HA.class "text-sm px-2 md:px-4 text-neutral-700" ] [ H.text poll.description ]

        -- Question Container
        , H.form
            [ HA.class "py-2 px-4 md:px-8" ]
            (List.indexedMap (viewPollField poll.id) poll.fields)
        , H.div [ HA.class "flex flex-row justify-end p-4" ] [ submitBtn poll.id ]
        ]


viewPollField : Id -> Int -> Field -> Html Msg
viewPollField pollId i field =
    let
        numbering =
            fromInt (i + 1) ++ ". "
    in
    case field of
        CharField { questionText, answer, id } ->
            H.div
                [ HA.class "p-2 flex flex-row flex-wrap" ]
                [ H.label [ HA.class "pr-2 flex-2" ] [ H.text (numbering ++ questionText) ]
                , H.input
                    [ HA.class <|
                        "flex-1 p-1 px-4 max-h-14 rounded-sm border-2 border-neutral-300 focus:border-0 "
                            ++ "bg-neutral-50 hover:bg-neutral-200 focus:bg-white focus:outline-neutral-300 "
                            ++ "focus:outline-1"
                    , HA.value (withDefault "" answer)
                    , HA.placeholder "answer.."
                    , HE.onInput (SetFieldAnswer pollId (Id <| unwrapId id ++ "_c"))
                    ]
                    []
                ]

        TextField { id, questionText, answer } ->
            H.div
                [ HA.class "p-2" ]
                [ H.label [] [ H.text (numbering ++ questionText) ]
                , H.div []
                    [ H.textarea
                        [ HA.class <|
                            "box-border h-max min-h-fit w-11/12 p-2 m-2 ml-8 rounded-sm border-2 border-neutral-300 bg-neutral-50 "
                                ++ "hover:bg-neutral-200 focus:bg-white h-fit focus:outline-neutral-300 focus:outline-1 "
                                ++ "overflow-auto resize-none scroll-py-2"
                        , HA.value (withDefault "" answer)
                        , HA.placeholder "Your text here"
                        , HA.rows 14
                        , HE.onInput (SetFieldAnswer pollId (Id <| unwrapId id ++ "_t"))
                        ]
                        []
                    ]
                ]

        ChoiceField { id, questionText, choices } ->
            H.fieldset
                [ HA.class "p-2" ]
                [ H.legend [] [ H.text (numbering ++ questionText) ]
                , H.div [ HA.class "px-4" ]
                    (List.indexedMap
                        (\j choice ->
                            H.div
                                []
                                [ H.input
                                    [ HA.type_ "radio"
                                    , HA.id <| unwrapId pollId ++ unwrapId id ++ fromInt j ++ "_ch"
                                    , HA.name <| "poll" ++ unwrapId pollId ++ unwrapId id
                                    , HA.value choice
                                    , HE.onInput <| SetFieldAnswer pollId (Id <| unwrapId id ++ "_ch")
                                    ]
                                    []
                                , H.label
                                    [ HA.for <| unwrapId pollId ++ unwrapId id ++ fromInt j ++ "_ch"
                                    , HA.class "px-2"
                                    ]
                                    [ H.text choice ]
                                ]
                        )
                        choices
                    )
                ]

        MultiChoiceField { id, questionText, choices } ->
            H.fieldset
                [ HA.class "p-2" ]
                [ H.legend [] [ H.text (numbering ++ questionText) ]
                , H.div [ HA.class "px-4" ]
                    (List.indexedMap
                        (\j choice ->
                            H.div
                                []
                                [ H.input
                                    [ HA.type_ "checkbox"
                                    , HA.id <| unwrapId pollId ++ unwrapId id ++ fromInt j ++ "_m"
                                    , HA.name <| "poll" ++ unwrapId pollId ++ unwrapId id
                                    , HA.value choice
                                    , HE.onInput <| SetFieldAnswer pollId (Id <| unwrapId id ++ "_m")
                                    ]
                                    []
                                , H.label
                                    [ HA.for <| unwrapId pollId ++ unwrapId id ++ fromInt j ++ "_m"
                                    , HA.class "px-2"
                                    ]
                                    [ H.text choice ]
                                ]
                        )
                        choices
                    )
                ]


submitBtn : Id -> Html Msg
submitBtn pollId =
    H.div [ HA.class "text-center mx-2" ]
        [ H.button
            [ HE.onClick (SubmitPoll pollId)
            , HA.class "px-4 bg-slate-900 p-2 rounded-md text-lg text-white m-2"
            ]
            [ H.text "Submit Poll" ]
        ]


navbar : Html Msg
navbar =
    H.nav
        [ HA.class "flex flex-row justify-between items-center py-4 px-6 w-full sm:w-5/6 lg:w-4/6 mx-auto " ]
        [ H.a
            [ HA.class "font-semibold text-2xl hover:underline hover:font-bold decoration-solid"
            , HA.href "/"
            ]
            [ H.text "Polls" ]
        , H.div [] []
        , H.div [] []
        , H.a
            [ HA.href "/blog"
            , HA.class "hover:decoration-solid text-lg hover:font-semibold hover:underline decoration-solid"
            ]
            [ H.text "Blog" ]
        , H.a
            [ HA.href "/login"
            , HA.class "bg-slate-900 text-white py-2 px-4 rounded-md hover:font-semibold"
            ]
            [ H.text "Login" ]
        ]


header : Html Msg
header =
    H.div
        [ HA.class "w-full sm:w-5/6 lg:w-4/6 mx-auto p-4 text-lg" ]
        [ H.text "Pulic Polls: " ]


refreshDataButton : Html Msg
refreshDataButton =
    H.div [ HA.class "text-center" ]
        [ H.button
            [ HE.onClick GetData
            , HA.class "bg-slate-800 py-2 px-4 rounded-md text-lg text-white m-2"
            ]
            [ H.text "Refresh Poll Data" ]
        ]
