module Pages.Polls.Pollid_ exposing (Model, Msg, page)

import Components.Navbar exposing (navbar)
import Data.Poll exposing (Field(..), Poll)
import Gen.Params.Polls.Pollid_ exposing (Params)
import Graphql.Http exposing (HttpError(..), RawError(..), mutationRequest, queryRequest, send)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Maybe exposing (withDefault)
import Page
import PollSelectionSets exposing (AddCharFieldAnswerPayload, allPolls, answerMutation)
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


type alias Model =
    RemoteData String (List Poll)


init : Request.With Params -> ( Model, Cmd Msg )
init { params } =
    let
        _ =
            Debug.log "" params.pollid

        req =
            allPolls
                |> queryRequest "http://localhost:8000/graphql/"
                |> send resultToMessage
    in
    ( NotAsked, req )



-- UPDATE


type Msg
    = GetData String
    | GotPolls (RemoteData (Graphql.Http.Error (List Poll)) (List Poll))
    | SetFieldAnswer String String String
    | SubmitPoll String
    | GotAnswer (Maybe AddCharFieldAnswerPayload)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GetData _, _ ) ->
            let
                req =
                    allPolls
                        |> queryRequest "http://localhost:8000/graphql/"
                        |> send resultToMessage
            in
            ( model, req )

        ( GotPolls webResult, _ ) ->
            ( RemoteData.mapError errorToString webResult, Cmd.none )

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

        ( GotAnswer _, _ ) ->
            -- let
            --     _ =
            --         Debug.log "answer res" a
            -- in
            ( model, Cmd.none )


resultToMessage : Result (Graphql.Http.Error (List Poll)) (List Poll) -> Msg
resultToMessage res =
    RemoteData.fromResult res
        |> GotPolls


errorToString : Graphql.Http.Error (List Poll) -> String
errorToString err =
    case err of
        GraphqlError _ _ ->
            "grqphql Error"

        HttpError httpError ->
            case httpError of
                Timeout ->
                    "Timeout"

                NetworkError ->
                    "NetworkError"

                BadStatus _ _ ->
                    "BadStatus"

                BadPayload _ ->
                    "BadPayload"

                BadUrl _ ->
                    "BadUrl"


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


fieldIdMatches : String -> Field -> Bool
fieldIdMatches fieldId field =
    case field of
        CharField { id } ->
            fieldId == (id ++ "_c")

        TextField { id } ->
            fieldId == (id ++ "_t")

        ChoiceField { id } ->
            fieldId == (id ++ "_ch")

        MultiChoiceField { id } ->
            fieldId == (id ++ "_m")



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
            [ HA.class "min-h-screen bg-neutral-100" ]
            [ navbar

            -- , header
            , content model
            ]
        ]
    }


content : Model -> Html Msg
content model =
    case model of
        NotAsked ->
            H.div [] []

        Loading ->
            H.div [] [ H.text "Loading" ]

        Failure failuremessage ->
            H.div
                [ HA.class "p-4 w-4/6 mx-auto" ]
                [ H.div [ HA.class "py-8 text-red-500" ]
                    [ H.p [] [ H.text <| "There has been a " ++ failuremessage ]
                    , H.p [] [ H.text "Click the button to refresh the poll" ]
                    ]

                --TODO(nathan): edit button to only get data from the poll in the url
                , refreshDataButton ""
                ]

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


viewPollField : String -> Int -> Field -> Html Msg
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
                    , HE.onInput (SetFieldAnswer pollId (id ++ "_c"))
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
                        , HE.onInput (SetFieldAnswer pollId (id ++ "_t"))
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
                                    , HA.id <| pollId ++ id ++ fromInt j ++ "_ch"
                                    , HA.name <| "poll" ++ pollId ++ id
                                    , HA.value choice
                                    , HE.onInput <| SetFieldAnswer pollId (id ++ "_ch")
                                    ]
                                    []
                                , H.label
                                    [ HA.for <| pollId ++ id ++ fromInt j ++ "_ch"
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
                                    , HA.id <| pollId ++ id ++ fromInt j ++ "_m"
                                    , HA.name <| "poll" ++ pollId ++ id
                                    , HA.value choice
                                    , HE.onInput <| SetFieldAnswer pollId (id ++ "_m")
                                    ]
                                    []
                                , H.label
                                    [ HA.for <| pollId ++ id ++ fromInt j ++ "_m"
                                    , HA.class "px-2"
                                    ]
                                    [ H.text choice ]
                                ]
                        )
                        choices
                    )
                ]


submitBtn : String -> Html Msg
submitBtn pollId =
    H.div [ HA.class "text-center mx-2" ]
        [ H.button
            [ HE.onClick (SubmitPoll pollId)
            , HA.class "px-4 bg-slate-900 p-2 rounded-md text-lg text-white m-2"
            ]
            [ H.text "Submit Poll" ]
        ]


refreshDataButton : String -> Html Msg
refreshDataButton id =
    H.div [ HA.class "text-center" ]
        [ H.button
            [ HE.onClick <| GetData id
            , HA.class "bg-slate-800 py-2 px-4 rounded-md text-lg text-white m-2"
            ]
            [ H.text "Refresh Poll Data" ]
        ]
