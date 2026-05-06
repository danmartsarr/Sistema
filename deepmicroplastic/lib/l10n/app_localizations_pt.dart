// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Sistema RAVI';

  @override
  String get appAcronymR => 'econhecimento';

  @override
  String get appAcronymA => 'utomatizado';

  @override
  String get appAcronymV => 'ia';

  @override
  String get appAcronymI => 'nfravermelho';

  @override
  String get appTagline => 'Identificação de Microplásticos por FTIR';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get language => 'Idioma';

  @override
  String get login => 'Entrar';

  @override
  String get loginInstitution => 'Instituição';

  @override
  String get loginInstitutionHint => 'ex.: usp';

  @override
  String get loginUsername => 'Usuário';

  @override
  String get loginPassword => 'Senha';

  @override
  String get loginEnter => 'ENTRAR';

  @override
  String get loginInstitutionContinue => 'CONTINUAR';

  @override
  String get loginInstitutionNotFound => 'Instituição não encontrada.';

  @override
  String get loginUserNotFound => 'Usuário ou senha incorretos.';

  @override
  String get loginFillAll => 'Preencha todos os campos.';

  @override
  String get loginFirstRunBanner =>
      'Primeira execução — crie o administrador do sistema e a primeira instituição.';

  @override
  String get loginCreateFirstAdmin => 'CRIAR CONTA ADMIN';

  @override
  String get loginNewInstitution => 'Cadastrar nova instituição';

  @override
  String get loginNewInstitutionDesc =>
      'Apenas administradores do sistema podem criar instituições.';

  @override
  String get loginAdminFullName => 'Nome completo do administrador';

  @override
  String get loginAdminEmail => 'E-mail do administrador';

  @override
  String get loginInstitutionName => 'Nome da instituição';

  @override
  String get loginPasswordMin => 'A senha deve ter no mínimo 6 caracteres.';

  @override
  String get loginInstitutionAlreadyExists =>
      'Já existe uma instituição com esse identificador.';

  @override
  String get loginCreateError => 'Erro ao criar. Verifique a conexão.';

  @override
  String get loginChangeInstitution => 'Trocar instituição';

  @override
  String get homeTitle => 'Análise FTIR';

  @override
  String get homeKpiTotalSamples => 'Total de amostras';

  @override
  String get homeKpiCollections => 'Coletas';

  @override
  String get homeKpiVerified => 'Verificadas';

  @override
  String get homePolymerDistribution => 'Distribuição de polímeros';

  @override
  String get homeRegisteredCollections => 'Coletas registradas';

  @override
  String get homeNoCollections =>
      'Nenhuma coleta cadastrada ainda.\nToque em \"Nova Coleta\" para começar.';

  @override
  String get homeNewCollection => 'Nova Coleta';

  @override
  String get homeMenuUsers => 'Gerenciar Usuários';

  @override
  String get homeMenuInstitutions => 'Gerenciar Instituições';

  @override
  String get homeMenuLanguage => 'Idioma';

  @override
  String get homeMenuLogout => 'Sair';

  @override
  String get homeLoadError => 'Erro ao carregar dados. Verifique a conexão.';

  @override
  String get homeRetry => 'Tentar novamente';

  @override
  String datasetSamples(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n amostras',
      one: '1 amostra',
    );
    return '$_temp0';
  }

  @override
  String get datasetRemoveTitle => 'Remover coleta?';

  @override
  String datasetRemoveBody(Object name) {
    return 'A coleta \"$name\" e todas as suas amostras serão removidas permanentemente.';
  }

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionRemove => 'Remover';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionImportCsv => 'Importar CSV';

  @override
  String get addDatasetTitle => 'Nova Coleta';

  @override
  String get addDatasetSectionId => 'IDENTIFICAÇÃO';

  @override
  String get addDatasetName => 'Nome da coleta';

  @override
  String get addDatasetNameHint => 'ex.: Praia do Futuro — Abr/2024';

  @override
  String get addDatasetDescription => 'Descrição';

  @override
  String get addDatasetDescriptionHint =>
      'ex.: Sedimento superficial em 5 pontos amostrais';

  @override
  String get addDatasetLocation => 'Localização';

  @override
  String get addDatasetLocationHint => 'ex.: Fortaleza, CE';

  @override
  String get addDatasetSectionEquipment => 'EQUIPAMENTO E CALIBRAÇÃO';

  @override
  String get addDatasetEquipmentNote =>
      'Parâmetros compartilhados por todas as amostras desta coleta.';

  @override
  String get addDatasetSpectrometerModel => 'Modelo do espectrômetro';

  @override
  String get addDatasetSpectrometerHint =>
      'ex.: Bruker Vertex 70 + Hyperion 3000';

  @override
  String get addDatasetAcquisitionMode => 'Modo de aquisição';

  @override
  String get addDatasetAtrCrystal => 'Cristal ATR';

  @override
  String get addDatasetDetector => 'Detector';

  @override
  String get addDatasetResolution => 'Resolução (cm⁻¹)';

  @override
  String get addDatasetScans => 'Nº de scans';

  @override
  String get addDatasetSectionDataType => 'TIPO DE DADO PADRÃO';

  @override
  String get addDatasetSave => 'SALVAR COLETA';

  @override
  String get addDatasetRequired => 'Campo obrigatório';

  @override
  String get addDatasetSaveError => 'Erro ao salvar. Verifique a conexão.';

  @override
  String get modeAtr => 'ATR';

  @override
  String get modeTransmission => 'Transmissão';

  @override
  String get modeReflection => 'Reflexão';

  @override
  String get dataAbsorbance => 'Absorbância';

  @override
  String get dataTransmittance => 'Transmitância';

  @override
  String get notInformed => 'Não informado';

  @override
  String get noDescription => 'Sem descrição.';

  @override
  String get datasetDetailUploadCsvTooltip => 'Importar CSV';

  @override
  String get datasetDetailNewSample => 'Nova Amostra';

  @override
  String get datasetDetailFilterAll => 'Todos';

  @override
  String get datasetDetailFilterPending => 'Pendente';

  @override
  String get datasetDetailColSample => 'Amostra';

  @override
  String get datasetDetailColLocation => 'Local';

  @override
  String get datasetDetailColPolymer => 'Polímero';

  @override
  String get datasetDetailColConfidence => 'Confiança';

  @override
  String get datasetDetailEmpty =>
      'Nenhuma amostra cadastrada.\nToque em \"Nova Amostra\" para começar.';

  @override
  String get datasetDetailEmptyFiltered => 'Nenhuma amostra para este filtro.';

  @override
  String get datasetDetailStatAnalyzed => 'Analisadas';

  @override
  String get datasetDetailStatVerified => 'Verificadas';

  @override
  String get datasetDetailStatAvgConf => 'Conf. média';

  @override
  String get datasetDetailPolymerDistribution => 'DISTRIBUIÇÃO DE POLÍMEROS';

  @override
  String get addSampleTitleNew => 'Nova Amostra';

  @override
  String get addSampleTitleEdit => 'Editar Amostra';

  @override
  String get addSampleModeIndividual => 'Amostra individual';

  @override
  String get addSampleModeBatch => 'Lote de amostras';

  @override
  String get addSampleSectionCollection => 'COLETA';

  @override
  String get addSampleSectionId => 'IDENTIFICAÇÃO';

  @override
  String get addSampleIdLabel => 'ID da amostra';

  @override
  String get addSampleIdRandom => 'Aleatório';

  @override
  String get addSampleSiteLabel => 'Local de coleta';

  @override
  String get addSampleSiteHint => 'ex.: Ponto 4 — Orla Norte';

  @override
  String get addSampleSectionDate => 'DATA DE COLETA';

  @override
  String get addSampleChangeDate => 'Alterar';

  @override
  String get addSampleSectionSpectral => 'DADOS ESPECTRAIS (OPCIONAL)';

  @override
  String get addSampleAttachCsv => 'Anexar dados espectrais (CSV, 1 linha)';

  @override
  String get addSampleAttachHelp =>
      'O CSV é enviado ao modelo MLP para identificação automática. Os dados ficam vinculados ao ID aleatório desta amostra.';

  @override
  String get addSampleAttachInvalid => 'CSV sem amostras válidas.';

  @override
  String get addSampleAttachLoading => 'Identificando…';

  @override
  String addSampleAttachLoadingFile(Object file) {
    return 'Identificando $file…';
  }

  @override
  String addSampleAttachMultiline(int n) {
    return 'CSV tem $n linhas. Apenas a primeira foi usada. Para importar todas, use o modo Lote.';
  }

  @override
  String addSampleAttachConfidenceShort(Object pct) {
    return '$pct% conf.';
  }

  @override
  String addSampleAttachPoints(int n) {
    return '$n pontos';
  }

  @override
  String get addSampleAttachRemoveTooltip => 'Remover anexo';

  @override
  String get addSampleSectionNotes => 'OBSERVAÇÕES';

  @override
  String get addSampleNotesLabel => 'Anotações';

  @override
  String get addSampleNotesHint =>
      'Morfologia, cor, tamanho, condições de coleta…';

  @override
  String get addSampleSectionVerification => 'VERIFICAÇÃO DO ANOTADOR';

  @override
  String get addSampleVerifiedToggle => 'Amostra verificada pelo anotador';

  @override
  String get addSampleSaveBtn => 'CADASTRAR AMOSTRA';

  @override
  String get addSampleSaveBtnEdit => 'SALVAR ALTERAÇÕES';

  @override
  String get addSampleBatchInfo =>
      'Cadastra múltiplas amostras com IDs aleatórios para um mesmo ponto de coleta. Use \"Importar de CSV\" para criar um lote já com dados espectrais e identificação.';

  @override
  String get addSampleBatchSectionCount => 'NÚMERO DE AMOSTRAS';

  @override
  String get addSampleBatchCount => 'Quantidade';

  @override
  String get addSampleBatchCountHint => 'ex.: 5';

  @override
  String get addSampleBatchSiteLabel => 'Local compartilhado';

  @override
  String get addSampleBatchSiteHint => 'ex.: Praia do Futuro — Transecto 2';

  @override
  String get addSampleBatchNotesLabel => 'Anotações (compartilhadas)';

  @override
  String get addSampleBatchNotesHint => 'Condições gerais da coleta…';

  @override
  String get addSampleBatchInvalidCount => 'Informe um número entre 1 e 50.';

  @override
  String get addSampleBatchSaveBtn => 'CADASTRAR LOTE (IDS ALEATÓRIOS)';

  @override
  String get addSampleBatchImportCsv => 'IMPORTAR LOTE A PARTIR DE CSV';

  @override
  String get addSampleSaveError => 'Erro ao salvar. Verifique a conexão.';

  @override
  String get sampleVerified => 'Amostra verificada';

  @override
  String sampleVerifiedBy(Object who) {
    return 'por $who';
  }

  @override
  String get sampleSectionInfo => 'INFORMAÇÕES DA AMOSTRA';

  @override
  String get sampleSectionCalibration => 'CALIBRAÇÃO DO EQUIPAMENTO';

  @override
  String get sampleMetaSite => 'Local';

  @override
  String get sampleMetaCollectionDate => 'Data de coleta';

  @override
  String get sampleMetaDataType => 'Tipo de dado';

  @override
  String get sampleMetaVerifiedBy => 'Verificado por';

  @override
  String get sampleMetaVerification => 'Verificação';

  @override
  String get sampleMetaPending => 'Pendente';

  @override
  String get sampleCalMode => 'Modo';

  @override
  String get sampleCalEquipment => 'Equipamento';

  @override
  String get sampleCalResolution => 'Resolução';

  @override
  String get sampleCalScans => 'Nº de scans';

  @override
  String get sampleCalDetector => 'Detector';

  @override
  String get sampleCalAtrCrystal => 'Cristal ATR';

  @override
  String get sampleSectionResult => 'ANÁLISE DO MODELO';

  @override
  String get sampleSectionPeaks => 'BANDAS DIAGNÓSTICAS';

  @override
  String get sampleSectionNotes => 'OBSERVAÇÕES';

  @override
  String get sampleSpectrumTitle => 'ESPECTRO FTIR';

  @override
  String get sampleIdentifyMlp => 'IDENTIFICAR COM MLP';

  @override
  String get sampleIdentifying => 'IDENTIFICANDO…';

  @override
  String get sampleIdentifyTooltip => 'Identificar com MLP';

  @override
  String get sampleNoServer =>
      'Não foi possível conectar ao servidor MLP. Verifique se mlp_server.py está em execução.';

  @override
  String sampleNoSpectrumLoading(Object id) {
    return 'Carregando espectro do servidor (ID $id)…';
  }

  @override
  String get sampleNoSpectrum =>
      'Sem dados espectrais para esta amostra. Anexe um CSV no cadastro ou use \"Importar CSV\".';

  @override
  String get sampleRemoveTitle => 'Remover amostra?';

  @override
  String sampleRemoveBody(Object name) {
    return 'A amostra \"$name\" será removida permanentemente.';
  }

  @override
  String get sampleResultLabel => 'Polímero identificado';

  @override
  String get sampleConfidence => 'confiança';

  @override
  String get sampleDecisionPoint => 'Ponto de decisão';

  @override
  String get chartAbsorbance => 'Absorbância';

  @override
  String get chartTransmittance => 'Transmitância';

  @override
  String get chartLegendDecision => 'Ponto de decisão';

  @override
  String get chartLegendAttention => 'Região de atenção';

  @override
  String get chartAttention => 'Atenção';

  @override
  String get importCsvTitle => 'Importar CSV';

  @override
  String get importCsvSectionFormat => 'FORMATO DO ARQUIVO';

  @override
  String get importCsvFormat1 => 'Cada linha do CSV = uma amostra espectral';

  @override
  String get importCsvFormat2 =>
      'Cabeçalhos numéricos (ex.: 600.0, 3998.0) = números de onda';

  @override
  String get importCsvFormat3 =>
      'Colunas categóricas (name, sample, interpretation…) são removidas automaticamente';

  @override
  String get importCsvFormat4 =>
      'O modelo MLP identifica: PE, PP, PS, PA, EVA, celulose';

  @override
  String get importCsvSectionFile => 'ARQUIVO';

  @override
  String get importCsvNoFile => 'Nenhum arquivo selecionado';

  @override
  String get importCsvChoose => 'Escolher';

  @override
  String get importCsvIdentify => 'IDENTIFICAR AMOSTRAS';

  @override
  String importCsvIdentifying(Object progress) {
    return 'IDENTIFICANDO $progress…';
  }

  @override
  String importCsvResults(int n) {
    return 'RESULTADOS ($n amostra(s))';
  }

  @override
  String importCsvHighConf(int n) {
    return '$n alta confiança';
  }

  @override
  String get importCsvSaving => 'SALVANDO…';

  @override
  String importCsvImport(int n) {
    return 'IMPORTAR $n AMOSTRA(S) PARA O DATASET';
  }

  @override
  String importCsvImportedToast(int n) {
    return '$n amostra(s) importada(s) com sucesso.';
  }

  @override
  String get manageUsersTitle => 'Usuários';

  @override
  String get manageUsersNew => 'Novo Usuário';

  @override
  String get manageUsersEmpty => 'Nenhum usuário cadastrado.';

  @override
  String get manageUsersRemoveTitle => 'Remover usuário?';

  @override
  String manageUsersRemoveBody(Object name) {
    return 'O usuário \"$name\" será removido permanentemente.';
  }

  @override
  String get manageUsersRoleAdmin => 'Administrador';

  @override
  String get manageUsersRoleResearcher => 'Pesquisador';

  @override
  String get manageUsersYou => 'você';

  @override
  String get manageUsersTooltipEdit => 'Editar';

  @override
  String get manageUsersTooltipRemove => 'Remover';

  @override
  String get userFormTitleNew => 'Novo Usuário';

  @override
  String get userFormTitleEdit => 'Editar Usuário';

  @override
  String get userFormSectionId => 'IDENTIFICAÇÃO';

  @override
  String get userFormUsername => 'Usuário (login)';

  @override
  String get userFormUsernameHint => 'ex.: jsilva';

  @override
  String get userFormFullName => 'Nome completo';

  @override
  String get userFormFullNameHint => 'ex.: João Silva';

  @override
  String get userFormEmail => 'E-mail institucional';

  @override
  String get userFormEmailHint => 'ex.: joao@usp.br';

  @override
  String get userFormDepartment => 'Departamento / Laboratório';

  @override
  String get userFormDepartmentHint => 'ex.: Lab. de Oceanografia';

  @override
  String get userFormSectionRole => 'PERFIL DE ACESSO';

  @override
  String get userFormRoleResearcher => 'Pesquisador';

  @override
  String get userFormRoleAdmin => 'Administrador';

  @override
  String get userFormSectionPasswordNew => 'SENHA';

  @override
  String get userFormSectionPasswordEdit => 'ALTERAR SENHA (opcional)';

  @override
  String get userFormPassword => 'Senha';

  @override
  String get userFormPasswordHintNew => 'Mín. 6 caracteres';

  @override
  String get userFormPasswordHintEdit => 'Deixe em branco para manter';

  @override
  String get userFormPasswordConfirm => 'Confirmar senha';

  @override
  String get userFormPasswordConfirmHint => 'Repita a senha';

  @override
  String get userFormPasswordsMismatch => 'As senhas não coincidem.';

  @override
  String get userFormPasswordTooShort =>
      'A senha deve ter no mínimo 6 caracteres.';

  @override
  String get userFormUsernameTaken => 'Esse nome de usuário já está em uso.';

  @override
  String get userFormSaveError => 'Erro ao salvar. Verifique a conexão.';

  @override
  String get userFormSaveBtnNew => 'CRIAR USUÁRIO';

  @override
  String get userFormSaveBtnEdit => 'SALVAR ALTERAÇÕES';

  @override
  String get manageInstitutionsTitle => 'Instituições';

  @override
  String get manageInstitutionsEmpty => 'Nenhuma instituição cadastrada.';

  @override
  String get manageInstitutionsNew => 'Nova Instituição';

  @override
  String get manageInstitutionsRemoveTitle => 'Remover instituição?';

  @override
  String manageInstitutionsRemoveBody(Object name) {
    return 'Todos os usuários, coletas e amostras de \"$name\" serão removidos permanentemente. Essa ação não pode ser desfeita.';
  }

  @override
  String manageInstitutionsCreatedAt(Object date) {
    return 'Criada em $date';
  }

  @override
  String get manageInstitutionsAdminOnly =>
      'Apenas administradores podem cadastrar novas instituições.';

  @override
  String get newInstitutionTitle => 'Cadastrar Instituição';

  @override
  String get newInstitutionInstName => 'Nome da instituição';

  @override
  String get newInstitutionInstNameHint => 'ex.: Universidade de São Paulo';

  @override
  String get newInstitutionSlug => 'Identificador (slug)';

  @override
  String get newInstitutionSlugHint => 'ex.: usp (gerado automaticamente)';

  @override
  String get newInstitutionAdminSection => 'ADMINISTRADOR INICIAL';

  @override
  String get newInstitutionCreate => 'CRIAR INSTITUIÇÃO';

  @override
  String get newInstitutionInstitution => 'INSTITUIÇÃO';

  @override
  String get newInstitutionAdminUsername => 'Usuário do admin';

  @override
  String get newInstitutionAdminUsernameHint => 'ex.: admin';

  @override
  String get newInstitutionAdminFullName => 'Nome do admin';

  @override
  String get newInstitutionAdminEmail => 'E-mail do admin';

  @override
  String get newInstitutionAdminPassword => 'Senha do admin';

  @override
  String newInstitutionSuccess(Object name) {
    return 'Instituição \"$name\" criada. Você já pode entrar.';
  }
}
