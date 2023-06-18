module Components.Navbar exposing (navbar)

import Data.User exposing (User)
import Gen.Route as Route exposing (Route(..))
import Html as H exposing (Html)
import Html.Attributes as HA


navbar : Maybe User -> Html msg
navbar user =
    H.nav
        [ HA.class "flex flex-row justify-between items-center py-4 px-6 w-full sm:w-5/6 lg:w-4/6 mx-auto " ]
        [ H.a
            [ HA.class "font-semibold text-2xl hover:underline hover:font-bold decoration-solid"
            , HA.href "/"
            ]
            [ H.text "Polly" ]
        , H.div [] []
        , H.div [] []
        , H.a
            [ HA.href "/blog"
            , HA.class "hover:decoration-solid text-lg hover:underline decoration-solid"
            ]
            [ H.text "Blog" ]
        , username_or_login_link user
        ]


username_or_login_link : Maybe User -> Html msg
username_or_login_link maybeUser =
    let
        -- _ =
        --     Debug.log "user" maybeUser
        commonStyles =
            "bg-slate-900 text-white py-2 px-4 rounded-md hover:underline"
    in
    case maybeUser of
        Just _ ->
            H.a
                [ HA.href (Route.toHref Auth__Logout)
                , HA.class commonStyles
                ]
                [ H.text "Log out" ]

        Nothing ->
            H.a
                [ HA.href (Route.toHref Auth__Login)
                , HA.class commonStyles
                ]
                [ H.text "Login" ]
