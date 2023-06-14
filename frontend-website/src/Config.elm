module Config exposing (apiTokenPath, localApiUri, localRootUri)


localApiUri : String
localApiUri =
    "http://localhost:8000/graphql/"


localRootUri : String
localRootUri =
    "http://localhost:8000"


apiTokenPath : String
apiTokenPath =
    "/auth/api-token/"
