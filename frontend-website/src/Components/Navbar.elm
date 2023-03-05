module Components.Navbar exposing (navbar)

import Html as H exposing (Html)
import Html.Attributes as HA


navbar : Html msg
navbar =
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
            , HA.class "hover:decoration-solid text-lg hover:font-semibold hover:underline decoration-solid"
            ]
            [ H.text "Blog" ]
        , H.a
            [ HA.href "/login"
            , HA.class "bg-slate-900 text-white py-2 px-4 rounded-md hover:font-semibold"
            ]
            [ H.text "Login" ]
        ]
