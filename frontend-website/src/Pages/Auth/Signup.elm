module Pages.Auth.Signup exposing (Model, Msg, page)

import Components.Navbar exposing (navbar)
import Data.User exposing (User)
import Effect exposing (Effect)
import Gen.Params.Auth.Signup exposing (Params)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Page
import Request
import Shared
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page { user } _ =
    Page.advanced
        { init = init user
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { signupForm : SignupForm
    , user : Maybe User
    }


type alias SignupForm =
    { username : String
    , password1 : String
    , password2 : String

    -- Do not show errors before form is first filled
    , filled : Bool
    }


init : Maybe User -> ( Model, Effect Msg )
init user =
    ( { user = user
      , signupForm =
            { username = ""
            , password1 = ""
            , password2 = ""
            , filled = False
            }
      }
    , Effect.none
    )



-- UPDATE


type FormField
    = Username
    | Password1
    | Password2


type Msg
    = UpdateFormField FormField String
    | Signup


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UpdateFormField field value ->
            ( { model
                | signupForm = updateForm model.signupForm field value
              }
            , Effect.none
            )

        Signup ->
            let
                cmd =
                    Cmd.none
            in
            ( model, Effect.fromCmd cmd )


updateForm : SignupForm -> FormField -> String -> SignupForm
updateForm model field value =
    case field of
        Username ->
            { model | username = value }

        Password1 ->
            { model | password1 = value }

        Password2 ->
            { model | password2 = value }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Polly | Signup"
    , body =
        [ navbar Nothing
        , H.div
            [ HA.class "w-4/6 mx-auto flex justify-center" ]
            [ viewSignupForm model.signupForm ]
        ]
    }


viewSignupForm : SignupForm -> Html Msg
viewSignupForm { username, password1, password2 } =
    H.div
        [ HA.class "" ]
        [ H.form
            [ HA.class "flex flex-col spacing-2"
            , HE.onSubmit Signup
            ]
            [ H.input
                [ HA.id "username-field"
                , HA.type_ "username"
                , HA.class "bg-slate-100"
                , HA.placeholder "username"
                , HA.required True
                , HA.value username
                , HE.onInput (UpdateFormField Username)
                ]
                []
            , H.input
                [ HA.id "password1-field"
                , HA.type_ "password"
                , HA.class "bg-slate-100"
                , HA.placeholder "Enter password"
                , HA.required True
                , HA.value password1
                , HE.onInput (UpdateFormField Password1)
                ]
                []
            , H.input
                [ HA.id "password2-field"
                , HA.type_ "password"
                , HA.class "bg-slate-100"
                , HA.placeholder "Enter password again"
                , HA.required True
                , HA.value password2
                , HE.onInput (UpdateFormField Password2)
                ]
                []
            , H.input
                [ HA.id "submit"
                , HA.type_ "submit"
                , HA.class "p-2 bg-slate-800 text-white rounded-md"
                , HA.value "Sign up"
                ]
                []
            ]
        ]
