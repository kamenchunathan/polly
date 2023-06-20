module Pages.Auth.Logout exposing (Model, Msg, page)

import Components.Navbar exposing (navbar)
import Effect exposing (Effect)
import Gen.Params.Auth.Logout exposing (Params)
import Gen.Route as Route
import Html as H exposing (Html)
import Html.Attributes as HA
import Page
import Request
import Shared exposing (Msg(..))
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ _ =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    {}


init : ( Model, Effect Msg )
init =
    ( {}, Effect.fromShared PerformLogout )


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Effect Msg )
update () _ =
    ( {}, Effect.none )


view : Model -> View Msg
view model =
    { title = "Polly | Logout"
    , body = body model
    }


body : Model -> List (Html Msg)
body _ =
    [ navbar Nothing
    , H.div
        [ HA.class "h-full grid" ]
        [ H.div
            [ HA.class "mx-auto mt-16 mb-auto" ]
            [ H.p
                [ HA.class "text-2xl " ]
                [ H.text "You have logged out" ]
            , H.a
                [ HA.href (Route.toHref Route.Auth__Login)
                , HA.class "font-semibold underline"
                ]
                [ H.text "Log in Again"
                ]
            , H.div [] []
            , H.a
                [ HA.href (Route.toHref Route.Home_)
                , HA.class "font-semibold underline"
                ]
                [ H.text "Go back home"
                ]
            ]
        ]
    ]
