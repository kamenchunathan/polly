module Pages.Polls.Pollid_ exposing (Model, Msg, page)

import Components.Navbar exposing (navbar)
import Data.Poll exposing (Field(..), Poll)
import Gen.Params.Polls.Pollid_ exposing (Params)
import Gen.Route as Route exposing (Route(..))
import Graphql.Http exposing (HttpError(..), RawError(..), mutationRequest, queryRequest, send)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Maybe exposing (withDefault)
import Page
import PollApi.Scalar exposing (Id(..))
import PollSelectionSets exposing (AddCharFieldAnswerPayload, answerMutation, specificPoll)
import RemoteData exposing (RemoteData(..))
import Request
import Shared
import String exposing (fromInt)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page { user } req_params =
    Page.element
        { init = init req_params user
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type RequestError
    = PollNotFound
    | Other String


type alias Model =
    { requestedPollId : String
    , poll : RemoteData RequestError Poll
    , req : Request.With Params
    , user : Maybe Shared.User
    }


query_request : String -> Maybe Shared.User -> Cmd Msg
query_request pollId user =
    specificPoll (Id pollId)
        |> queryRequest "http://localhost:8000/graphql/"
        |> Graphql.Http.withOperationName "initial_request"
        |> Maybe.withDefault identity (Maybe.map (\{ authToken } -> Graphql.Http.withHeader "Authorization" ("Bearer " ++ authToken)) user)
        |> send (resultToMessage GotPoll)


init : Request.With Params -> Maybe Shared.User -> ( Model, Cmd Msg )
init ({ params } as req) user =
    ( { requestedPollId = params.pollid
      , poll = NotAsked
      , req = req
      , user = Nothing
      }
    , query_request params.pollid user
    )



-- UPDATE


type Msg
    = GetData
    | GotPoll (RemoteData (Graphql.Http.Error (Maybe Poll)) (Maybe Poll))
    | SetFieldAnswer String String String
    | SubmitPoll
      -- TODO(nathan): Rename this to something more descriptive
    | GotAnswer (Maybe AddCharFieldAnswerPayload)


propagateError : RemoteData RequestError (Maybe a) -> RemoteData RequestError a
propagateError res =
    case res of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failure e ->
            Failure e

        Success (Just val) ->
            Success val

        Success Nothing ->
            Failure PollNotFound


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetData ->
            let
                req =
                    specificPoll (Id model.requestedPollId)
                        |> queryRequest "http://localhost:8000/graphql/"
                        |> send (resultToMessage GotPoll)
            in
            ( model, req )

        GotPoll webResult ->
            let
                poll =
                    RemoteData.mapError errorToString webResult
                        |> propagateError
            in
            ( { model | poll = poll }, Cmd.none )

        SetFieldAnswer pollId fieldId val ->
            let
                newPoll =
                    RemoteData.map
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
                        model.poll
            in
            ( { model | poll = newPoll }
            , Cmd.none
            )

        SubmitPoll ->
            let
                req =
                    mutationRequest "http://localhost:8000/graphql/" answerMutation
                        |> send payloadResultToMessage
            in
            ( model, req )

        GotAnswer _ ->
            -- let
            --     _ =
            --         Debug.log "answer res" a
            -- in
            ( model, Cmd.none )


resultToMessage : (RemoteData e a -> Msg) -> Result e a -> Msg
resultToMessage msg res =
    RemoteData.fromResult res
        |> msg


errorToString : Graphql.Http.Error a -> RequestError
errorToString err =
    case err of
        GraphqlError _ _ ->
            Other "grqphql Error"

        HttpError httpError ->
            case httpError of
                Timeout ->
                    Other "Timeout"

                NetworkError ->
                    Other "NetworkError"

                BadStatus _ _ ->
                    Other "BadStatus"

                BadPayload _ ->
                    Other "BadPayload"

                BadUrl _ ->
                    Other "BadUrl"


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
    case model.poll of
        NotAsked ->
            H.div [] []

        Loading ->
            H.div [] [ H.text "Loading" ]

        Failure (Other failuremessage) ->
            H.div
                [ HA.class "p-4 w-4/6 mx-auto" ]
                [ H.div [ HA.class "py-8 text-red-500" ]
                    [ H.p [] [ H.text <| "There has been a " ++ failuremessage ]
                    , H.p [] [ H.text "Click the button to refresh the poll" ]
                    ]

                --TODO(nathan): edit button to only get data from the poll in the url
                , refreshDataButton
                ]

        Failure PollNotFound ->
            viewPollNotFound

        Success poll ->
            viewPoll poll


viewPollNotFound : Html msg
viewPollNotFound =
    H.div
        [ HA.class "p-4 w-4/6 mx-auto" ]
        [ H.div [ HA.class "py-8 text-red-500" ]
            [ H.p []
                [ H.text <|
                    "This poll does not exist. You may have gotten an incorrect url or"
                        ++ " it may have been deleted by the owner"
                ]
            ]
        , H.a
            [ HA.class "underline font-semibold text-xl"
            , HA.href (Route.toHref Route.Home_)
            ]
            [ H.text "Take me back home"
            ]
        ]


viewPoll : Poll -> Html Msg
viewPoll poll =
    H.div [ HA.class " w-4/6 mx-auto" ]
        [ H.div
            [ HA.class "p-2 m-2 md:px-4" ]
            [ H.p [ HA.class "text-lg font-medium" ] [ H.text poll.title ]
            , H.p [ HA.class "text-sm px-2 md:px-4 text-neutral-700" ] [ H.text poll.description ]

            -- Question Container
            , H.form
                [ HA.class "py-2 px-4 md:px-8" ]
                (List.indexedMap (viewPollField poll.id) poll.fields)
            , H.div [ HA.class "flex flex-row justify-end p-4" ] [ submitBtn poll.id ]
            ]
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
submitBtn _ =
    H.div [ HA.class "text-center mx-2" ]
        [ H.button
            [ HE.onClick SubmitPoll
            , HA.class "px-4 bg-slate-900 p-2 rounded-md text-lg text-white m-2"
            ]
            [ H.text "Submit Poll" ]
        ]


refreshDataButton : Html Msg
refreshDataButton =
    H.div [ HA.class "text-center" ]
        [ H.button
            [ HE.onClick GetData
            , HA.class "bg-slate-800 py-2 px-4 rounded-md text-lg text-white m-2"
            ]
            [ H.text "Refresh Poll Data" ]
        ]
