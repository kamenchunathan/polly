module Pages.NotFound exposing (view)

import Components.Navbar exposing (navbar)
import Html as H exposing (Html)
import Html.Attributes as HA
import View exposing (View)


view : View msg
view =
    { title = "Not Found"
    , body = [ body ]
    }


body : Html msg
body =
    H.div
        []
        [ -- hard coded emtpy user is temprorary
          -- TODO: Add user here
          navbar Nothing
        , header
        , content
        ]


content : Html msg
content =
    H.div [ HA.class "w-4/6 mx-auto text-lg py-16" ]
        [ H.p [] [ H.text "It seems you're lost, And we're not quite sure where you wanted to go. " ]
        , H.p []
            [ H.text "Home's only one click away though. "
            , H.a
                [ HA.class "font-semibold underline decoration-solid font-xl"
                , HA.href "/"
                ]
                [ H.text "Take me back home" ]
            ]
        ]


header : Html msg
header =
    H.header
        []
        [ H.h3
            [ HA.class "w-5/6 mx-auto my-6 font-semibold text-2xl text-center" ]
            [ H.text "Page not found"
            ]
        ]
