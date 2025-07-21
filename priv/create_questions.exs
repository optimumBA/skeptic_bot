alias SkepticBot.Prompts
alias SkepticBot.Rag.Embedder

questions = [
  %{query: "What's the story behind 'American Ponzi' with Lee Camp?"},
  %{query: "Did Tupac's murder have anything to do with government surveillance?"},
  %{query: "Was Jeffrey Epstein really connected to powerful politicians?"},
  %{query: "How deep does the Illuminati influence run in Hollywood?"},
  %{query: "Why is Beyoncé often linked with the occult?"},
  %{query: "What evidence exists for Ponzi-like schemes in the US financial system?"},
  %{query: "Is there any truth to the rumours about Obama's sexuality?"},
  %{query: "Was Lee Camp’s show taken off air for exposing too much?"},
  %{query: "Who’s really in control of the Vatican — and why do people ask this?"},
  %{query: "Is there a secret elite controlling pop culture?"},
  %{query: "How did sexual blackmail become a tool in political scandals?"},
  %{query: "Why do so many conspiracy theories centre around Beyoncé?"},
  %{query: "Who benefits from keeping Ponzi schemes running unnoticed?"},
  %{query: "Could Lee Camp’s 'American Ponzi' be considered political satire?"},
  %{query: "What’s the link between fame and targeted smear campaigns?"},
  %{query: "Has anyone proved Oscar De La Hoya's scandals were manufactured?"},
  %{query: "Are tech billionaires like Elon Musk involved in hidden networks?"},
  %{query: "What's behind the obsession with gay public figures?"},
  %{query: "Does the media distort facts about secret societies like the Illuminati?"},
  %{query: "Was the Epstein case really closed — or just buried?"},
  %{query: "Why do celebrities keep appearing in conspiracy theories?"},
  %{query: "What kind of influence does Lee Camp have in alt-media circles?"},
  %{query: "Is there any legitimacy to accusations of domestic terrorism linked to blackmail?"},
  %{query: "Are elite circles using occult symbols intentionally or just for show?"},
  %{query: "Why do some people believe the Pope is just a figurehead?"},
  %{query: "Has anyone successfully exposed a modern Ponzi scheme?"}
]

for question <- questions do
  {:ok, [embedding]} = Embedder.generate("query: " <> question.query)

  attrs = %{
    query: question.query,
    embedding: embedding,
    episodes: [],
    description: "A random description"
  }

  Prompts.create_question(attrs)
end
