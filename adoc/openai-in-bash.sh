
== openAI wrapper for bash
:toc:
:source-highlighter: rouge


[source,shell]
----
export OPENAI_API_KEY=$(gopass -o openai-api-key)
sudo zypper install python3 python3-pip kubernetes-client
python3 -m venv ~/.venvs/kloggpt
source ~/.venvs/kloggpt/bin/activate
pip install openai

# modell list
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  | jq '.data[].id'

export OPENAI_MODEL="modell"

----

