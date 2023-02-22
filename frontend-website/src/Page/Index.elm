module Page.Index exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import Graphql.Http exposing (queryRequest, send)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Head
import Head.Seo as Seo
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Http
import Maybe exposing (withDefault)
import Page exposing (StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path
import PollApi.Object.Poll as Poll
import PollApi.Object.PollCharField as PollCharField
import PollApi.Object.PollChoiceField as PollChoiceField
import PollApi.Object.PollMultiChoiceField as PollMultiChoiceField
import PollApi.Object.PollTextField as PollTextField
import PollApi.Query exposing (polls)
import PollApi.Scalar exposing (Id(..))
import PollApi.Union.PollField exposing (Fragments, fragments)
import Shared
import String exposing (fromInt)
import View exposing (View)


type alias Model =
    { polls : List Poll
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


type Msg
    = GetData
    | NoOpString String
    | GotPolls (List Poll)
    | SetFieldAnswer Id Id String
    | SubmitPoll Id


type alias RouteParams =
    {}


page : Page.PageWithState RouteParams Data Model Msg
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithSharedState
            { init = init
            , view = view
            , update = update
            , subscriptions = subscriptions
            }


init :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload templateData routeParams
    -> ( Model, Cmd Msg )
init _ _ _ =
    let
        test_req =
            Http.get
                { url = "http://localhost:8000/auth/user/"
                , expect = Http.expectString (Result.withDefault "" >> NoOpString)
                }
    in
    ( { polls = [] }
    , test_req
    )


update :
    PageUrl
    -> Maybe Browser.Navigation.Key
    -> Shared.Model
    -> StaticPayload templateData routeParams
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Maybe Shared.Msg )
update _ _ _ _ msg model =
    case msg of
        GetData ->
            let
                req =
                    pollSelectionSet
                        |> queryRequest "http://localhost:8000/graphql/"
                        |> send resultToMessage
            in
            ( model, req, Nothing )

        NoOpString s ->
            let
                _ =
                    Debug.log "server test" s
            in
            ( model, Cmd.none, Nothing )

        GotPolls polls ->
            ( { model | polls = polls }, Cmd.none, Nothing )

        SetFieldAnswer pollId fieldId val ->
            let
                polls =
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
                        model.polls
            in
            ( { model | polls = polls }, Cmd.none, Nothing )

        SubmitPoll pollId ->
            Debug.todo "branch 'SubmitPoll _' not implemented"



-- SetMultiChoiceFieldAnswer ->
--     let
--         polls =
--             []
--     in
--     ( { model | polls = polls }, Cmd.none, Nothing )


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
                let
                    _ =
                        Debug.log "ping pong" "wow"
                in
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


pollSelectionSet : SelectionSet (List Poll) RootQuery
pollSelectionSet =
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



-- _ ->
--     ( model, Cmd.none, Nothing )


subscriptions :
    Maybe PageUrl
    -> routeParams
    -> Path.Path
    -> Model
    -> Shared.Model
    -> Sub Msg
subscriptions _ _ _ _ _ =
    Sub.none


data : DataSource Data
data =
    DataSource.succeed ()


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title"
        }
        |> Seo.website


type alias Data =
    ()


view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload templateData routeParams
    -> View Msg
view _ _ { polls } _ =
    { title = "Home | Polls"
    , body =
        [ H.div
            [ HA.class "h-screen bg-neutral-50" ]
            [ navbar
            , header
            , viewPolls polls
            , if List.isEmpty polls then
                getDataButton

              else
                H.div [] []
            ]
        ]
    }


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
                            ++ "bg-neutral-100 hover:bg-neutral-200 focus:bg-white focus:outline-neutral-500 "
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
                            "box-border h-max min-h-fit w-11/12 p-2 m-2 ml-8 rounded-sm border-2 border-neutral-300 bg-neutral-100 "
                                ++ "hover:bg-neutral-200 focus:bg-white h-fit focus:outline-neutral-500 focus:outline-1 "
                                ++ "overflow-auto resize-none"
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
                                    , HA.name <| "poll" ++ unwrapId pollId
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
                                    , HA.name <| "poll" ++ unwrapId pollId
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


unwrapId : Id -> String
unwrapId (Id inner) =
    inner


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


getDataButton : Html Msg
getDataButton =
    H.div [ HA.class "text-center" ]
        [ H.button
            [ HE.onClick GetData
            , HA.class "bg-slate-800 py-2 px-4 rounded-md text-lg text-white m-2"
            ]
            [ H.text "All Public Polls" ]
        ]
