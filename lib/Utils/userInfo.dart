String urlBase = "https://cop-4331-large-project.herokuapp.com";
String accessToken = "", id = "", email = "";

void setAccessToken(String input)
{
  accessToken = input;
}

void setId(String input)
{
  id = input;
}

void setEmail(String input)
{
  email = input;
}

String getAccessToken()
{
  return accessToken;
}

String getId()
{
  return id;
}

String getEmail()
{
  return email;
}