module Pages.Home_ exposing (Model, Msg, page)

import Components.Navbar exposing (navbar)
import Data.User exposing (User)
import Gen.Params.Home_ exposing (Params)
import Gen.Route exposing (Route(..), toHref)
import Html as H exposing (Html)
import Html.Attributes as HA
import Page
import Request
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page { user } _ =
    Page.sandbox
        { init = init user
        , update = update
        , view = view
        }


type alias Model =
    { currentUser : Maybe User }


init : Maybe User -> Model
init currentUser =
    -- let
    --     _ =
    --         Debug.log "Logged in user" currentUser
    -- in
    { currentUser = currentUser }


type alias Msg =
    ()


update : Msg -> Model -> Model
update _ model =
    model


view : Model -> View Msg
view { currentUser } =
    { title = "Polls | Homepage"
    , body = [ body currentUser ]
    }


body : Maybe User -> Html msg
body currentUser =
    H.div [ HA.class "min-h-screen bg-neutral-100" ]
        [ navbar currentUser
        , header
        , content
        ]


header : Html msg
header =
    H.div [ HA.class "w-5/6 mx-auto mt-12" ]
        [ H.h1 [ HA.class "text-3xl font-semibold" ] [ H.text "The Best Polling platform" ]
        , H.p
            [ HA.class "py-4 text-lg" ]
            [ H.text "A platform to create versatile polls, share them, collect and analyze the data received " ]
        , callToAction
        ]


content : Html msg
content =
    H.div [ HA.class "w-5/6 mx-auto text-lg" ]
        [ -- TODO: for testing authentication. Remove
          H.a [ HA.href "/polls/5" ] [ H.text "Poll 5" ]
        , creatingPolls
        , sharingPolls
        , dataAnalysis
        ]


sharingPolls : Html msg
sharingPolls =
    H.section
        [ HA.class "py-4" ]
        [ H.h2
            [ HA.class "underline text-xl font-semibold py-4" ]
            [ H.text "Sharing and Targetting your Polls" ]
        , H.p
            [ HA.class "text-lg font-semibold" ]
            [ H.text "Offering a variety of ways to target your polls and reach your intended audience." ]
        , H.p
            []
            [ H.text <|
                String.join " "
                    [ "Polly allows you create publicly available polls and share them through a permanent link,"
                    , "create private polls that require authentication or Use our platform to target the"
                    , "polls to reach your desired audience based on precise criteria that you choose such"
                    , "as geographical location, occupation, gender and many others"
                    ]
            ]
        ]


dataAnalysis : Html msg
dataAnalysis =
    H.section
        [ HA.class "py-4" ]
        [ H.h2
            [ HA.class "underline text-xl font-semibold py-4" ]
            [ H.text "Understand and Visualize your data" ]
        , H.p
            []
            [ H.text <|
                String.join " "
                    [ "We offer a vast array of tools for summarizing, analyzing and visualizing the data you've collected"
                    ]
            ]
        ]


creatingPolls : Html msg
creatingPolls =
    H.section
        [ HA.class "py-4" ]
        [ H.h2
            [ HA.class "underline text-xl font-semibold py-4" ]
            [ H.text "Create polls that suit you" ]
        , H.p [] [ H.text "With Polly, you can create polls and questionnaires that suit your specific needs" ]
        ]


callToAction : Html msg
callToAction =
    H.div [ HA.class "flex flex-row justify-end w-4/6 mx-auto" ]
        [ H.a
            [ HA.href (toHref Auth__Signup)
            , HA.class "px-4 bg-slate-900 p-2 rounded-md text-lg text-white m-2"
            ]
            [ H.text "Get Started with Polly" ]
        ]
