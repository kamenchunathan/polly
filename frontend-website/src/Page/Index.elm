module Page.Index exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html as H exposing (Html)
import Html.Attributes as HA
import Page exposing (StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path
import Shared
import View exposing (View)


type alias Model =
    Int


type alias Poll =
    { title : String
    }


type alias Msg =
    ()


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
    ( 0, Cmd.none )


update :
    PageUrl
    -> Maybe Browser.Navigation.Key
    -> Shared.Model
    -> StaticPayload templateData routeParams
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Maybe Shared.Msg )
update _ _ _ _ _ _ =
    ( 0, Cmd.none, Nothing )


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
view _ _ _ _ =
    { title = "Home | Polls"
    , body =
        [ navbar
        , header
        ]
    }


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
        [ H.text "Home Page" ]


viewUserPolls : List Poll -> Html Msg
viewUserPolls userPolls =
    case userPolls of
        [] ->
            H.div [] []

        polls ->
            H.div [] (List.map (\poll -> H.div [] [ H.text poll.title ]) polls)
