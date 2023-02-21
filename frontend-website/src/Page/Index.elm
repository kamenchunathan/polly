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
import Page exposing (StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path
import PollApi.Object.Poll exposing (description, pollFields, title)
import PollApi.Object.PollCharField as PollCharField
import PollApi.Object.PollChoiceField as PollChoiceField
import PollApi.Object.PollMultiChoiceField as PollMultiChoiceField
import PollApi.Object.PollTextField as PollTextField
import PollApi.Query exposing (polls)
import PollApi.Scalar exposing (Id(..))
import PollApi.Union.PollField exposing (Fragments, fragments, maybeFragments)
import Shared
import View exposing (View)


type alias Model =
    { polls : List Poll
    }


type
    Field
    -- short text input (<100 characters)
    = CharField
        { questionText : String
        , answer : Maybe String
        }
      -- long text input
    | TextField
        { questionText : String
        , answer : Maybe String
        }
      -- choice between a list of options
    | ChoiceField
        { questionText : String
        }
      -- list of selected choices from a set of options
    | MultiChoiceField
        { questionText : String
        }


type alias Poll =
    { title : String
    , description : String
    , fields : List Field
    }


type Msg
    = GetData
    | NoOpString String
    | GotPolls (List Poll)


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


pollSelectionSet : SelectionSet (List Poll) RootQuery
pollSelectionSet =
    pollFields (fragments charFieldFragments)
        |> SelectionSet.map3 makePoll title description
        |> polls


charFieldFragments : Fragments Field
charFieldFragments =
    { onPollCharField =
        SelectionSet.map
            (\text -> CharField { questionText = text, answer = Nothing })
            PollCharField.text
    , onPollTextField =
        SelectionSet.map
            (\text -> TextField { questionText = text, answer = Nothing })
            PollTextField.text
    , onPollChoiceField =
        SelectionSet.map
            (\text -> ChoiceField { questionText = text })
            PollChoiceField.text
    , onPollMultiChoiceField =
        SelectionSet.map
            (\text -> MultiChoiceField { questionText = text })
            PollMultiChoiceField.text
    }


makePoll : String -> String -> List Field -> Poll
makePoll title description fields =
    { title = title
    , description = description
    , fields = fields
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
        [ navbar
        , header
        , viewPolls polls
        , getDataButton
        ]
    }


viewPollField : Field -> Html Msg
viewPollField field =
    case field of
        CharField { questionText } ->
            H.div
                [ HA.class "inline-block" ]
                [ H.text questionText ]

        TextField { questionText } ->
            H.span [] [ H.text questionText ]

        ChoiceField { questionText } ->
            H.span [] [ H.text questionText ]

        MultiChoiceField { questionText } ->
            H.span [] [ H.text questionText ]


viewPolls : List Poll -> Html Msg
viewPolls polls =
    H.div
        [ HA.class "p-4 w-4/6 mx-auto" ]
        (List.map viewPoll polls)


viewPoll : Poll -> Html Msg
viewPoll poll =
    H.div
        [ HA.class "p-2 m-2 bg-blue-200" ]
        [ H.p [ HA.class "text-lg " ] [ H.text poll.title ]
        , H.p [ HA.class "text-sm px-2" ] [ H.text poll.description ]

        -- Question Container
        , H.form
            [ HA.class "py-2 px-4" ]
            (List.indexedMap
                (\i x ->
                    -- Question
                    H.div []
                        [ H.text <| String.fromInt (i + 1) ++ ". "
                        , viewPollField x
                        ]
                )
                poll.fields
            )
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
            , HA.class "bg-black text-white py-2 px-4 rounded-md hover:font-semibold"
            ]
            [ H.text "Login" ]
        ]


header : Html Msg
header =
    H.div
        [ HA.class "h-full w-full sm:w-5/6 lg:w-4/6 mx-auto p-4" ]
        [ H.text "Polls You've created" ]


getDataButton : Html Msg
getDataButton =
    H.div [ HA.class "text-center" ]
        [ H.button
            [ HE.onClick GetData
            , HA.class "bg-blue-600 p-2  rounded-md text-xl text-white m-2"
            ]
            [ H.text "Fetch Polls" ]
        ]
