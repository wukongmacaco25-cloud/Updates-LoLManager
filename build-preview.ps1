$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path preview-app, release | Out-Null

@'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net8.0-windows</TargetFramework>
    <UseWindowsForms>true</UseWindowsForms>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <RuntimeIdentifier>win-x64</RuntimeIdentifier>
    <SelfContained>true</SelfContained>
    <PublishSingleFile>true</PublishSingleFile>
    <PublishTrimmed>false</PublishTrimmed>
    <AssemblyName>Financial-Recovery-Portable-v0.1.1</AssemblyName>
  </PropertyGroup>
</Project>
'@ | Set-Content -Encoding UTF8 preview-app/FinancialRecoveryPreview.csproj

@'
using System;
using System.Drawing;
using System.Globalization;
using System.Windows.Forms;

namespace FinancialRecoveryPreview;

internal static class Program
{
    [STAThread]
    static void Main()
    {
        Application.SetHighDpiMode(HighDpiMode.PerMonitorV2);
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Application.Run(new MainForm());
    }
}

internal sealed class MainForm : Form
{
    readonly Color Bg = Color.FromArgb(12,19,32), Side = Color.FromArgb(8,14,24), Card = Color.FromArgb(17,27,44), Soft = Color.FromArgb(25,38,58), Main = Color.FromArgb(237,243,251), Muted = Color.FromArgb(151,166,186), Accent = Color.FromArgb(131,149,255), Danger = Color.FromArgb(255,140,155), Good = Color.FromArgb(110,215,175), Warn = Color.FromArgb(243,183,101);
    readonly Panel content = new() { Dock = DockStyle.Fill, AutoScroll = true };
    readonly Label title = new();

    public MainForm()
    {
        Text = "Financial Recovery — Desktop Preview v0.1.1";
        Width = 1440; Height = 900; MinimumSize = new Size(1080,700); StartPosition = FormStartPosition.CenterScreen;
        BackColor = Bg; ForeColor = Main; Font = new Font("Segoe UI", 10);

        var root = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 2, RowCount = 1, BackColor = Bg };
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute,236)); root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,100));
        Controls.Add(root); root.Controls.Add(MakeSidebar(),0,0);

        var right = new TableLayoutPanel { Dock = DockStyle.Fill, RowCount = 2, ColumnCount = 1, BackColor = Bg };
        right.RowStyles.Add(new RowStyle(SizeType.Absolute,72)); right.RowStyles.Add(new RowStyle(SizeType.Percent,100));
        root.Controls.Add(right,1,0); right.Controls.Add(MakeTopbar(),0,0);
        content.BackColor = Bg; content.Padding = new Padding(30,24,30,30); right.Controls.Add(content,0,1);
        Dashboard();
    }

    Control MakeSidebar()
    {
        var p = new Panel { Dock = DockStyle.Fill, BackColor = Side, Padding = new Padding(14,20,14,14) };
        p.Controls.Add(new Label { Text = "FR   Financial Recovery\n      Desktop Preview", Dock = DockStyle.Top, Height = 62, ForeColor = Color.White, Font = new Font("Segoe UI Semibold",12), Padding = new Padding(8,4,0,0) });
        var nav = new FlowLayoutPanel { Dock = DockStyle.Top, Height = 590, FlowDirection = FlowDirection.TopDown, WrapContents = false, Padding = new Padding(0,12,0,0), BackColor = Side };
        p.Controls.Add(nav); nav.BringToFront();
        AddNav(nav,"▣  Visão geral",Dashboard); AddNav(nav,"▤  Contas",Accounts); AddNav(nav,"↕  Transações",Transactions); AddNav(nav,"◆  Dívidas",Debts); AddNav(nav,"◫  Orçamento",Budget); AddNav(nav,"◉  Simulador",Simulator); AddNav(nav,"➜  Estratégia",Strategy); AddNav(nav,"▦  Calendário",Calendar); AddNav(nav,"▤  Documentos",Documents); AddNav(nav,"⚙  Ajustes",Settings);
        p.Controls.Add(new Label { Text = "●  Ambiente DEMO", Dock = DockStyle.Bottom, Height = 34, ForeColor = Good, Padding = new Padding(10,8,0,0) });
        return p;
    }

    void AddNav(FlowLayoutPanel p,string text,Action action)
    {
        var b = new Button { Text=text, Width=202, Height=44, Margin=new Padding(0,2,0,2), TextAlign=ContentAlignment.MiddleLeft, Padding=new Padding(12,0,0,0), FlatStyle=FlatStyle.Flat, BackColor=Side, ForeColor=Color.FromArgb(190,202,219), Cursor=Cursors.Hand };
        b.FlatAppearance.BorderSize=0; b.FlatAppearance.MouseOverBackColor=Color.FromArgb(28,41,64); b.Click += (_,_)=>action(); p.Controls.Add(b);
    }

    Control MakeTopbar()
    {
        var p = new Panel { Dock=DockStyle.Fill, BackColor=Card };
        title.Text="Visão geral"; title.ForeColor=Main; title.Font=new Font("Segoe UI Semibold",13); title.AutoSize=true; title.Location=new Point(30,25); p.Controls.Add(title);
        var user = new Label { Text="JF    João Ferreira\n        Ambiente DEMO", AutoSize=true, ForeColor=Main, Font=new Font("Segoe UI",9), Anchor=AnchorStyles.Top|AnchorStyles.Right, Location=new Point(980,17) }; p.Controls.Add(user);
        p.Resize += (_,_)=> user.Left=Math.Max(600,p.ClientSize.Width-user.Width-28); return p;
    }

    void Reset(string page)
    {
        title.Text=page; content.Controls.Clear();
    }

    Label H(string eyebrow,string main,string sub) => new() { Text=$"{eyebrow.ToUpperInvariant()}\n{main}\n{sub}", Dock=DockStyle.Top, Height=92, ForeColor=Main, Font=new Font("Segoe UI Semibold",13), Padding=new Padding(0,4,0,0) };

    Panel Box(string head,string body,int h=150)
    {
        var p=new Panel { Dock=DockStyle.Top, Height=h, BackColor=Card, Padding=new Padding(20), Margin=new Padding(0,0,0,14) };
        p.Controls.Add(new Label { Text=body, AutoSize=true, ForeColor=Muted, Font=new Font("Segoe UI",10.5f), Location=new Point(20,54) });
        p.Controls.Add(new Label { Text=head, AutoSize=true, ForeColor=Main, Font=new Font("Segoe UI Semibold",13), Location=new Point(20,17) });
        return p;
    }

    Panel Metric(string k,string v,string d,Color c)
    {
        var p=new Panel { Width=255, Height=104, BackColor=Card, Margin=new Padding(0,0,14,0) };
        p.Controls.Add(new Label { Text=k.ToUpperInvariant(), AutoSize=true, ForeColor=Muted, Font=new Font("Segoe UI Semibold",8), Location=new Point(16,14) });
        p.Controls.Add(new Label { Text=v, AutoSize=true, ForeColor=c, Font=new Font("Segoe UI Semibold",17), Location=new Point(16,38) });
        p.Controls.Add(new Label { Text=d, AutoSize=true, ForeColor=Muted, Font=new Font("Segoe UI",8.5f), Location=new Point(16,76) }); return p;
    }

    void Dashboard()
    {
        Reset("Visão geral"); content.Controls.Add(H("VISÃO GERAL","Olá, João","Seu panorama financeiro está atualizado no modo demonstração."));
        var m=new FlowLayoutPanel { Dock=DockStyle.Top, Height=120, WrapContents=false, BackColor=Bg };
        m.Controls.Add(Metric("Patrimônio","R$ 18.420,00","Saldo e reservas",Good)); m.Controls.Add(Metric("Dívida total","R$ 22.710,00","R$ 4.200 em atraso",Danger)); m.Controls.Add(Metric("Capacidade mensal","R$ 1.880,00","Após despesas atuais",Accent)); m.Controls.Add(Metric("Juros estimados","R$ 991,60","Custo aproximado/mês",Warn)); content.Controls.Add(m); m.BringToFront();
        var a=Box("⚠  ATENÇÃO PRIORITÁRIA — Cartão Platinum","Saldo: R$ 4.200,00   |   Parcela: R$ 980,00   |   Taxa: 14,60% ao mês   |   Atraso: 18 dias\n\nAção: interromper o crescimento do saldo e priorizar renegociação/quitação.",145); content.Controls.Add(a); a.BringToFront();
        var h=Box("Saúde financeira                                      72 / 100","+12  Renda recorrente       +8  Reserva disponível\n−13  Dívida rotativa         −7  Comprometimento de renda\n\nA nota é explicável e reproduzível; não é uma caixa-preta.",165); content.Controls.Add(h); h.BringToFront();
        var d=Box("Dívidas que mais exigem ação","CRÍTICA   Cartão Platinum        R$ 4.200,00   14,60% a.m.\nALTA       Banco Horizonte        R$ 6.850,00    2,95% a.m.\nMÉDIA      Financeira Estrada     R$ 8.400,00    1,42% a.m.\nBAIXA      Loja Casa Nova         R$ 3.260,00    0,00% a.m.",185); content.Controls.Add(d); d.BringToFront();
    }

    void Page(string page,string sub,string body,int h=360)
    {
        Reset(page); content.Controls.Add(H(page,page,sub)); var b=Box(page,body,h); content.Controls.Add(b); b.BringToFront();
    }

    void Accounts()=>Page("Contas","Saldo consolidado","Banco Aurora         Conta corrente      R$ 6.840,00\nBanco Horizonte      Conta corrente      R$ 3.580,00\nCorretora Vertex     Investimentos       R$ 8.000,00");
    void Transactions()=>Page("Transações","Últimas movimentações","10/09   Salário                  + R$ 5.200,00\n10/09   Mercado Bom Dia           − R$   286,40\n09/09   Energia                   − R$   238,90\n08/09   Combustível               − R$   180,00\n07/09   Internet                  − R$   119,90");
    void Debts()=>Page("Central de dívidas","Prioridade por custo e risco","CRÍTICA — Cartão Platinum\nSaldo R$ 4.200,00 | 14,60% a.m. | 18 dias em atraso\nMotivo: maior custo mensal do portfólio.\n\nALTA — Banco Horizonte\nSaldo R$ 6.850,00 | 2,95% a.m.\nMotivo: custo relevante e parcela elevada.\n\nMÉDIA — Financeira Estrada\nSaldo R$ 8.400,00 | 1,42% a.m.\nMotivo: contrato mais barato e em dia.",420);
    void Budget()=>Page("Orçamento","Planejado x realizado","Moradia          R$ 1.800 de R$ 1.900\nAlimentação      R$ 1.080 de R$ 1.200\nTransporte       R$   620 de R$   700\nLazer            R$   310 de R$   450");
    void Strategy()=>Page("Estratégia","Plano de recuperação","PASSO 1 — Eliminar o saldo mais caro\nPriorizar Cartão Platinum sem comprometer despesas essenciais.\n\nPASSO 2 — Banco Horizonte\nComparar CET, renegociação e eventual portabilidade.\n\nPASSO 3 — Manter contratos baratos em dia\nParcela menor não significa custo total menor.",420);
    void Calendar()=>Page("Calendário","Próximos compromissos","12 SET   Energia              R$ 238,90\n14 SET   Cartão Platinum     R$ 980,00\n16 SET   Internet            R$ 119,90\n20 SET   Financiamento       R$ 745,00");
    void Documents()=>Page("Documentos","Importações financeiras","OFX, CSV e relatório SCR entram nas próximas fases.\n\nNesta versão DEMO nenhuma integração bancária é fingida como real.");
    void Settings()=>Page("Ajustes","Preferências locais","Ambiente: DEMO seguro\nTema: escuro\nDados: fictícios\nVersão: 0.1.1 Preview");

    void Simulator()
    {
        Reset("Simulador"); content.Controls.Add(H("SIMULADOR","E se eu pagar um valor extra?","Cálculo demonstrativo e determinístico."));
        var p=Box("Pagamento extra","",360); var l=new Label { Text="Valor extra neste mês (R$)", AutoSize=true, ForeColor=Muted, Location=new Point(24,65) }; var input=new TextBox { Text="500", Width=220, Location=new Point(24,92), BackColor=Soft, ForeColor=Main, BorderStyle=BorderStyle.FixedSingle }; var r=new Label { Text="", AutoSize=true, ForeColor=Good, Location=new Point(24,180), Font=new Font("Segoe UI Semibold",11) }; var b=new Button { Text="Calcular impacto", Width=185, Height=38, Location=new Point(260,88), BackColor=Accent, ForeColor=Color.White, FlatStyle=FlatStyle.Flat }; b.FlatAppearance.BorderSize=0;
        b.Click += (_,_)=> { if(decimal.TryParse(input.Text.Replace(',','.'),NumberStyles.Any,CultureInfo.InvariantCulture,out var x)&&x>=0){ var saldo=4200m; var ns=Math.Max(0,saldo-x); var save=(saldo-ns)*0.146m; r.Text=$"Novo saldo estimado: R$ {ns:N2}\nRedução aproximada do próximo mês de juros: R$ {save:N2}\n\nPreview local; o projeto principal mantém o motor financeiro em Rust."; } };
        p.Controls.AddRange(new Control[]{l,input,b,r}); content.Controls.Add(p); p.BringToFront();
    }
}
'@ | Set-Content -Encoding UTF8 preview-app/Program.cs

dotnet publish preview-app/FinancialRecoveryPreview.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o release
if (!(Test-Path release/Financial-Recovery-Portable-v0.1.1.exe)) { throw 'EXE não foi gerado.' }
Get-Item release/Financial-Recovery-Portable-v0.1.1.exe | Format-List Name,Length,FullName
