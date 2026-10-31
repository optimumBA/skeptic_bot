# This file contains the configuration for Credo and you are probably reading
# this after creating it with `mix credo.gen.config`.
#
# If you find anything wrong or unclear in this file, please report an
# issue on GitHub: https://github.com/rrrene/credo/issues
#
%{
  #
  # You can have as many configs as you like in the `configs:` field.
  configs: [
    %{
      #
      # Run any config using `mix credo -C <name>`. If no config name is given
      # "default" is used.
      #
      name: "default",
      #
      # These are the files included in the analysis:
      files: %{
        #
        # You can give explicit globs or simply directories.
        # In the latter case `**/*.{ex,exs}` will be used.
        #
        included: [
          "mix.exs",
          "config/",
          "priv/repo/seeds.exs",
          "priv/repo/seeds/",
          "priv/repo/migrations/",
          "lib/",
          "src/",
          "test/",
          "web/",
          "apps/*/lib/",
          "apps/*/src/",
          "apps/*/test/",
          "apps/*/web/"
        ],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      #
      # Load and configure plugins here:
      #
      plugins: [],
      #
      # If you create your own checks, you must specify the source files for
      # them here, so they can be loaded by Credo before running the analysis.
      #
      requires: [],
      #
      # If you want to enforce a style guide and need a more traditional linting
      # experience, you can change `strict` to `true` below:
      #
      strict: true,
      #
      # To modify the timeout for parsing files, change this value:
      #
      parse_timeout: 5000,
      #
      # If you want to use uncolored output by default, you can change `color`
      # to `false` below:
      #
      color: true,
      #
      # You can customize the parameters of any check by adding a second element
      # to the tuple.
      #
      # To disable a check put `false` as second element:
      #
      #     {Credo.Check.Design.DuplicatedCode, false}
      #
      checks: %{
        enabled: [
          #
          ## Consistency Checks
          #
          {Credo.Check.Consistency.ExceptionNames, []},
          {Credo.Check.Consistency.LineEndings, []},
          {Credo.Check.Consistency.ParameterPatternMatching, []},
          {Credo.Check.Consistency.SpaceAroundOperators, []},
          {Credo.Check.Consistency.SpaceInParentheses, []},
          {Credo.Check.Consistency.TabsOrSpaces, []},

          #
          ## Design Checks
          #
          # You can customize the priority of any check
          # Priority values are: `low, normal, high, higher`
          #
          {Credo.Check.Design.AliasUsage,
           [
             priority: :low,
             if_nested_deeper_than: 2,
             if_called_more_often_than: 0,
             files: %{
               excluded: [
                 "lib/skeptic_bot_web/components/core_components.ex"
               ]
             }
           ]},

          # You can also customize the exit_status of each check.
          # If you don't want TODO comments to cause `mix credo` to fail, just
          # set this value to 0 (zero).
          #
          {Credo.Check.Design.TagFIXME, [exit_status: 0]},
          {Credo.Check.Design.TagTODO, [exit_status: 0]},

          #
          ## Readability Checks
          #
          {Credo.Check.Readability.AliasOrder, []},
          {Credo.Check.Readability.FunctionNames, []},
          {Credo.Check.Readability.LargeNumbers, []},
          {Credo.Check.Readability.MaxLineLength, [priority: :low, max_length: 120]},
          {Credo.Check.Readability.ModuleAttributeNames, []},
          {Credo.Check.Readability.ModuleDoc, []},
          {Credo.Check.Readability.ModuleNames, []},
          {Credo.Check.Readability.ParenthesesInCondition, []},
          {Credo.Check.Readability.ParenthesesOnZeroArityDefs, []},
          {Credo.Check.Readability.PipeIntoAnonymousFunctions, []},
          {Credo.Check.Readability.PredicateFunctionNames, []},
          {Credo.Check.Readability.PreferImplicitTry, []},
          {Credo.Check.Readability.RedundantBlankLines, []},
          {Credo.Check.Readability.Semicolons, []},
          {Credo.Check.Readability.SpaceAfterCommas, []},
          {Credo.Check.Readability.StringSigils, []},
          {Credo.Check.Readability.TrailingBlankLine, []},
          {Credo.Check.Readability.TrailingWhiteSpace, []},
          {Credo.Check.Readability.UnnecessaryAliasExpansion, []},
          {Credo.Check.Readability.VariableNames, []},
          {Credo.Check.Readability.WithSingleClause, []},

          #
          ## Refactoring Opportunities
          #
          {Credo.Check.Refactor.Apply, []},
          {Credo.Check.Refactor.CondStatements, []},
          {Credo.Check.Refactor.CyclomaticComplexity, []},
          {Credo.Check.Refactor.FilterCount, []},
          {Credo.Check.Refactor.FilterFilter, []},
          {Credo.Check.Refactor.FunctionArity, []},
          {Credo.Check.Refactor.LongQuoteBlocks, []},
          {Credo.Check.Refactor.MapJoin, []},
          {Credo.Check.Refactor.MatchInCondition, []},
          {Credo.Check.Refactor.NegatedConditionsInUnless, []},
          {Credo.Check.Refactor.NegatedConditionsWithElse, []},
          {Credo.Check.Refactor.Nesting, files: %{excluded: ["lib/skeptic_bot/release.ex"]}},
          {Credo.Check.Refactor.RedundantWithClauseResult, []},
          {Credo.Check.Refactor.RejectReject, []},
          {Credo.Check.Refactor.UnlessWithElse, []},
          {Credo.Check.Refactor.UtcNowTruncate, []},
          {Credo.Check.Refactor.WithClauses, []},

          #
          ## Warnings
          #
          {Credo.Check.Warning.ApplicationConfigInModuleAttribute, []},
          {Credo.Check.Warning.BoolOperationOnSameValues, []},
          {Credo.Check.Warning.Dbg, []},
          {Credo.Check.Warning.ExpensiveEmptyEnumCheck, []},
          {Credo.Check.Warning.IExPry, []},
          {Credo.Check.Warning.IoInspect, []},
          {Credo.Check.Warning.MissedMetadataKeyInLoggerConfig, []},
          {Credo.Check.Warning.OperationOnSameValues, []},
          {Credo.Check.Warning.OperationWithConstantResult, []},
          {Credo.Check.Warning.RaiseInsideRescue, []},
          {Credo.Check.Warning.SpecWithStruct, []},
          {Credo.Check.Warning.UnsafeExec, []},
          {Credo.Check.Warning.UnusedEnumOperation, []},
          {Credo.Check.Warning.UnusedFileOperation, []},
          {Credo.Check.Warning.UnusedKeywordOperation, []},
          {Credo.Check.Warning.UnusedListOperation, []},
          {Credo.Check.Warning.UnusedPathOperation, []},
          {Credo.Check.Warning.UnusedRegexOperation, []},
          {Credo.Check.Warning.UnusedStringOperation, []},
          {Credo.Check.Warning.UnusedTupleOperation, []},
          {Credo.Check.Warning.WrongTestFileExtension, []},

          #
          ## Controversial and experimental checks
          #
          {Credo.Check.Consistency.MultiAliasImportRequireUse, []},
          {Credo.Check.Consistency.UnusedVariableNames, []},
          {Credo.Check.Design.DuplicatedCode, []},
          {Credo.Check.Design.SkipTestWithoutComment, []},
          {Credo.Check.Readability.AliasAs, []},
          {Credo.Check.Readability.BlockPipe, []},
          {Credo.Check.Readability.ImplTrue, []},
          {Credo.Check.Readability.MultiAlias, []},
          {Credo.Check.Readability.NestedFunctionCalls, []},
          {Credo.Check.Readability.OneArityFunctionInPipe, []},
          {Credo.Check.Readability.OnePipePerLine, []},
          {Credo.Check.Readability.SeparateAliasRequire, []},
          {Credo.Check.Readability.SingleFunctionToBlockPipe, []},
          {Credo.Check.Readability.SinglePipe, []},
          {Credo.Check.Readability.Specs,
           files: %{
             excluded: [
               "lib/skeptic_bot_web.ex",
               "lib/skeptic_bot_web/components/core_components.ex",
               "lib/skeptic_bot_web/controllers/error_html.ex",
               "lib/skeptic_bot_web/controllers/error_json.ex"
             ]
           }},
          {Credo.Check.Readability.StrictModuleLayout,
           order: [:shortdoc, :moduledoc, :use, :import, :alias, :require, :behaviour]},
          {Credo.Check.Readability.WithCustomTaggedTuple, []},
          {Credo.Check.Refactor.ABCSize, []},
          {Credo.Check.Refactor.AppendSingleItem, []},
          {Credo.Check.Refactor.DoubleBooleanNegation, []},
          {Credo.Check.Refactor.FilterReject, []},
          {Credo.Check.Refactor.IoPuts, []},
          {Credo.Check.Refactor.MapMap, []},
          {Credo.Check.Refactor.ModuleDependencies,
           max_deps: 20,
           files: %{
             excluded: [
               "lib/skeptic_bot/application.ex",
               "lib/skeptic_bot/podcasts/downloading_worker.ex"
             ]
           }},
          {Credo.Check.Refactor.NegatedIsNil, []},
          {Credo.Check.Refactor.PassAsyncInTestCases, []},
          {Credo.Check.Refactor.PipeChainStart, excluded_functions: ["from"]},
          {Credo.Check.Refactor.RejectFilter, []},
          {Credo.Check.Refactor.VariableRebinding, []},
          {Credo.Check.Warning.LeakyEnvironment, []},
          {Credo.Check.Warning.MapGetUnsafePass, []},
          {Credo.Check.Warning.MixEnv, []},
          {Credo.Check.Warning.UnsafeToAtom, []},

          # Project review conventions; KogenCredo separately owns integrity checks.
          {OptimumCredo.Check.Readability.AssignOrder, []},
          {OptimumCredo.Check.Readability.AssignThree, []},
          {OptimumCredo.Check.Readability.BannedAbbreviations, []},
          {OptimumCredo.Check.Readability.BooleanFunctionName, []},
          {OptimumCredo.Check.Readability.CastListOrder, []},
          {OptimumCredo.Check.Readability.DefaultCallbackDefined, []},
          {OptimumCredo.Check.Readability.DepsOrder, []},
          # These groups cover multiple callbacks or XML/error behavior across functions.
          {OptimumCredo.Check.Readability.DescribeFunctionArity,
           [
             allowed_patterns: [
               "^on_mount :\\w+$",
               "^PredictionHandler$",
               "^error handling$",
               "^XML pattern matching$"
             ]
           ]},
          {OptimumCredo.Check.Readability.DocumentationFormatting, []},
          {OptimumCredo.Check.Readability.EventNameSnakeCase, []},
          {OptimumCredo.Check.Readability.ExtractableSpecTypes, []},
          {OptimumCredo.Check.Readability.FunctionOrder, [function_order: :callers_first]},
          {OptimumCredo.Check.Readability.GenericModuleName, []},
          {OptimumCredo.Check.Readability.GettextDomain, []},
          {OptimumCredo.Check.Readability.ImplementationHelperInAssertion, []},
          {OptimumCredo.Check.Readability.ImportOrder, []},
          {OptimumCredo.Check.Readability.LlmScaffoldingComment, []},
          {OptimumCredo.Check.Readability.MaybePrefix, []},
          {OptimumCredo.Check.Readability.ModuleAttributeListOrder,
           [ignore_attributes: [:fields]]},
          {OptimumCredo.Check.Readability.ModuleOrganization, []},
          {OptimumCredo.Check.Readability.ModulePathMismatch, []},
          {OptimumCredo.Check.Readability.ModuleSelfPrefix, []},
          {OptimumCredo.Check.Readability.PrivateFunctionSpecs, []},
          {OptimumCredo.Check.Readability.RedundantBooleanComparison, []},
          {OptimumCredo.Check.Readability.RedundantFinalAssignment, []},
          {OptimumCredo.Check.Readability.SchemaFieldOrder, []},
          {OptimumCredo.Check.Readability.SingleElementTupleMessage, []},
          {OptimumCredo.Check.Readability.SpecWithImpl, []},
          {OptimumCredo.Check.Readability.TestNameLowercase, []},
          {OptimumCredo.Check.Readability.TestNameRepeatsSubject, []},
          {OptimumCredo.Check.Readability.TestPathMismatch, []},
          {OptimumCredo.Check.Readability.TypeParenthesesConsistency, []},
          {OptimumCredo.Check.Readability.TypespecOrder, []},
          {OptimumCredo.Check.Readability.UnusedTypes, []},
          {OptimumCredo.Check.Readability.VerboseAssertions, []},
          {OptimumCredo.Check.Refactor.AdjacentClauseOneLiteral, []},
          {OptimumCredo.Check.Refactor.CaseTrueFalse, []},
          {OptimumCredo.Check.Refactor.ConditionalOnParameter, []},
          {OptimumCredo.Check.Refactor.DuplicateHandleEvent, []},
          {OptimumCredo.Check.Refactor.LiveViewBareMatch, []},
          {OptimumCredo.Check.Refactor.RepeatedLiteral, []},
          {OptimumCredo.Check.Refactor.SchemaTableNameMismatch, [allow_context_prefix: true]},
          {OptimumCredo.Check.Refactor.ToggleOnlyHandleEvent, []},
          {OptimumCredo.Check.Refactor.WithElseManyClauses, []},
          {OptimumCredo.Check.Warning.AshCallWithoutActor, []},
          {OptimumCredo.Check.Warning.AshUpsertOptions, []},
          {OptimumCredo.Check.Warning.AsyncFalseWithoutComment, []},
          {OptimumCredo.Check.Warning.AuthorizeFalseWithoutComment, []},
          # Phoenix.ConnTest intentionally configures callers with @endpoint.
          {OptimumCredo.Check.Warning.CallerModuleAttributes, [allow_attributes: [:endpoint]]},
          {OptimumCredo.Check.Warning.CommentedOutCode, []},
          {OptimumCredo.Check.Warning.DescribeWithoutErrorCase, []},
          {OptimumCredo.Check.Warning.EnvVarWithoutFailure, []},
          {OptimumCredo.Check.Warning.ExplicitIndexName, []},
          {OptimumCredo.Check.Warning.ExternalCallInMigration, []},
          {OptimumCredo.Check.Warning.HardcodedAssetPath, []},
          {OptimumCredo.Check.Warning.HardcodedYearInTest, []},
          {OptimumCredo.Check.Warning.HiddenIdInput, []},
          {OptimumCredo.Check.Warning.HttpClientInTest, []},
          {OptimumCredo.Check.Warning.LoggerErrorWithoutContext, []},
          {OptimumCredo.Check.Warning.MixOutsideBuildConfig, []},
          {OptimumCredo.Check.Warning.NarrowRandomRange, []},
          {OptimumCredo.Check.Warning.NotNullWithoutDefault, []},
          {OptimumCredo.Check.Warning.RawSqlIndexInMigration, []},
          {OptimumCredo.Check.Warning.ReferenceWithoutOnDelete, []},
          {OptimumCredo.Check.Warning.RepoCallInEnumeration, []},
          {OptimumCredo.Check.Warning.RequiredFieldConsistency, []},
          {OptimumCredo.Check.Warning.SchemaModuleInMigration, []},
          {OptimumCredo.Check.Warning.SeedInsertWithoutOnConflict, []},
          {OptimumCredo.Check.Warning.SleepInTest, []},
          {OptimumCredo.Check.Warning.SleepOutsideTest, []},
          {OptimumCredo.Check.Warning.StaleRenderBinding, []},
          {OptimumCredo.Check.Warning.TestWithoutAssertion, []},
          {OptimumCredo.Check.Warning.UnsafeAtomConversion, []},
          # Canonical outbound URLs require the endpoint and router, but not web internals.
          {OptimumCredo.Check.Warning.WebNamespaceInCore,
           [allowed_modules: [SkepticBotWeb.Endpoint, SkepticBotWeb.Router]]},

          # Generated-code quality and test integrity.
          {KogenCredo.Check.Readability.EmptySetupBlock, []},
          {KogenCredo.Check.Readability.ErrorReasonString,
           [
             excluded_paths: [
               "lib/skeptic_bot/podcasts/req_downloader.ex",
               "lib/skeptic_bot/podcasts/yt_dlp_downloader.ex",
               "lib/skeptic_bot/podcasts/ffmpeg_transcoder.ex",
               "lib/skeptic_bot/storage/tigris_storage_provider.ex",
               "lib/skeptic_bot/replicate_client.ex",
               "lib/skeptic_bot/sitemap.ex",
               "lib/skeptic_bot_web/plugs/"
             ]
           ]},
          {KogenCredo.Check.Readability.JustifiedCoverageIgnore, []},
          {KogenCredo.Check.Readability.MapGetAtomKey, []},
          {KogenCredo.Check.Refactor.DomainSize,
           [
             domains: [
               [
                 name: "podcasts",
                 paths: ["lib/skeptic_bot/podcasts.ex", "lib/skeptic_bot/podcasts/"]
               ],
               [name: "rag", paths: ["lib/skeptic_bot/rag.ex", "lib/skeptic_bot/rag/"]],
               [
                 name: "questions",
                 paths: ["lib/skeptic_bot/prompts.ex", "lib/skeptic_bot/prompts/"]
               ],
               [name: "web", paths: ["lib/skeptic_bot_web/"]]
             ]
           ]},
          {KogenCredo.Check.Refactor.DuplicateHelper, []},
          {KogenCredo.Check.Refactor.SizeLimits,
           [excluded_paths: ["lib/skeptic_bot_web/components/core_components.ex"]]},
          {KogenCredo.Check.Warning.BroadRescue,
           [excluded_paths: ["lib/skeptic_bot/podcasts/yt_dlp_downloader.ex"]]},
          {KogenCredo.Check.Warning.CtxBag, []},
          {KogenCredo.Check.Warning.DiscardedResult, []},
          # DomainReach needs an accepted cross-domain contract map; not a dormant gate.
          {KogenCredo.Check.Warning.FailOpenWith, []},
          {KogenCredo.Check.Warning.ForbiddenCall, [presets: [:async_safe_tests]]},
          {KogenCredo.Check.Warning.GlobalNameInventory, []},
          {KogenCredo.Check.Warning.GlobalStateInAsync,
           [
             case_templates: %{
               "SkepticBot.DataCase" => :inherit,
               "SkepticBotWeb.ConnCase" => :inherit
             }
           ]},
          {KogenCredo.Check.Warning.LimitWithoutStableOrder, []},
          {KogenCredo.Check.Warning.NoCredoDisable, []},
          {KogenCredo.Check.Warning.NoGlobalTeardown,
           [
             case_templates: %{
               "SkepticBot.DataCase" => :inherit,
               "SkepticBotWeb.ConnCase" => :inherit
             }
           ]},
          {KogenCredo.Check.Warning.PathExpandPriv, []},
          {KogenCredo.Check.Warning.RepoAllThenTrim, []},
          {KogenCredo.Check.Warning.RepoInLoop, []},
          {KogenCredo.Check.Warning.RuntimeEnvDevDefault, []},
          {KogenCredo.Check.Warning.SerialReason,
           [
             case_templates: %{
               "SkepticBot.DataCase" => :inherit,
               "SkepticBotWeb.ConnCase" => :inherit
             }
           ]},
          {KogenCredo.Check.Warning.SharedResourceGroup,
           [
             case_templates: %{
               "SkepticBot.DataCase" => :inherit,
               "SkepticBotWeb.ConnCase" => :inherit
             }
           ]},
          {KogenCredo.Check.Warning.SkippedTest, []},
          {KogenCredo.Check.Warning.StringKeyAccess,
           [
             codec_modules: [
               SkepticBot.WebhookHandler,
               SkepticBot.ReplicateClient,
               SkepticBot.Podcasts.TinfoilScraper,
               SkepticBot.Podcasts.ReplicateTranscriber,
               SkepticBot.Podcasts.TranscribingWorker,
               SkepticBot.YtDlp.EpisodeProcessor,
               SkepticBotWeb.Plugs.VerifyReplicateWebhook
             ]
           ]},
          {KogenCredo.Check.Warning.StubBody, []},
          {KogenCredo.Check.Warning.TestFsHygiene, []},
          {KogenCredo.Check.Warning.TestHasNoAssertions, []},
          {KogenCredo.Check.Warning.TestModuleShape,
           [
             serial_allowed: [
               "test/skeptic_bot/prediction_handler_test.exs",
               "test/skeptic_bot/podcasts/downloading_worker_test.exs",
               "test/skeptic_bot/workers/sitemap_generator_worker_test.exs"
             ]
           ]},
          {KogenCredo.Check.Warning.UnboundedWait, []},
          {KogenCredo.Check.Warning.UnescapedLikeInput, []},
          {KogenCredo.Check.Warning.VacuousTest, []},
          {KogenCredo.Check.Warning.VariableModuleCall,
           [excluded_paths: ["lib/skeptic_bot/replicate_client.ex", "lib/skeptic_bot/release.ex"]]},
          {KogenCredo.Check.Warning.WeakAssertion, []}
        ],
        disabled: [
          #
          # Checks scheduled for next check update (opt-in for now, just replace `false` with `[]`)

          #
          # Controversial and experimental checks (opt-in, just move the check to `:enabled`
          #   and be sure to use `mix credo --strict` to see low priority checks)
          #
          {Credo.Check.Warning.LazyLogging, []}

          # {Credo.Check.Refactor.MapInto, []},

          #
          # Custom checks can be created using `mix credo.gen.check`.
          #
        ]
      }
    }
  ]
}
