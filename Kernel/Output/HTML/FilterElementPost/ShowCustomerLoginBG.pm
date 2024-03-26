# --
# Copyright (C) 2001-2024 OTRS AG, https://otrs.com/
# --
# $origin: otrs - 0000000000000000000000000000000000000000 - Kernel/Output/HTML/FilterElementPost/ShowCustomerLoginBG.pm
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Output::HTML::FilterElementPost::ShowCustomerLoginBG;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
);

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

# ---
    # Customer Login Background
# ---
    if ( $Param{TemplateFile} eq 'CustomerLogin' )
    {
        if ( defined $ConfigObject->Get('CustomerLoginBackground') )
        {
            my %CustomerLoginBackground = %{ $ConfigObject->Get('CustomerLoginBackground') };
            my %Data;

            for my $CSSStatement ( sort keys %CustomerLoginBackground ) {
                if ( $CSSStatement eq 'BackgroundURL' ) {
                    my $WebPath = '';
                    if ( $CustomerLoginBackground{$CSSStatement} !~ /(http|ftp|https):\//i ) {
                        $WebPath = $ConfigObject->Get('Frontend::WebPath');
                    }
                    $Data{'BackgroundURL'} = 'url(' . $WebPath . $CustomerLoginBackground{$CSSStatement} . ')';
                }
                else {
                    $Data{$CSSStatement} = $CustomerLoginBackground{$CSSStatement};
                }
            }

            my $CSS = qq~<style type="text/css">
            #LoginBG {
                width: $Data{'BackgroundWidth'};
                height: $Data{'BackgroundHeight'};
                background: $Data{'BackgroundURL'};
                position: $Data{'BackgroundPosition'};
                background-repeat: $Data{'BackgroundRepeat'};
                background-attachment: $Data{'BackgroundAttachment'};
                background-size: $Data{'BackgroundSize'};
                z-index: $Data{'Backgroundz-index'};
            }
            </style>
            ~;

            #set background div and set mainbox to have transparent background
            my $SearchField1 = quotemeta "<div id=\"MainBox\" class=\"Login ARIARoleMain\">";
            my $ReturnField1 = qq~$CSS <div id="LoginBG"></div>
            <div id="MainBox" class="Login ARIARoleMain" style="background:transparent;">
            ~;

            #search and replace
            ${ $Param{Data} } =~ s{$SearchField1}{$ReturnField1};

            #check if transparent header is needed
            if ( $Data{'TransparentHeader'} )
            {
                #set header background as transparent
                my $SearchFieldHeader = quotemeta "<div id=\"Header\">";
                my $ReturnFieldHeader
                    = qq~<div id="Header" style="background:transparent; border-bottom-color:transparent;">~;

                #search and replace
                ${ $Param{Data} } =~ s{$SearchFieldHeader}{$ReturnFieldHeader};
            }

            #check if transparent footer is needed
            if ( $Data{'TransparentFooter'} )
            {
                #set footer background as transparent
                my $SearchFieldFooter = quotemeta "<div id=\"Footer\" class=\"ARIARoleContentinfo\">";
                my $ReturnFieldFooter
                    = qq~ <div id="Footer" class="ARIARoleContentinfo" style="background:transparent; border-top-color:transparent;"> ~;

                #search and replace
                ${ $Param{Data} } =~ s{$SearchFieldFooter}{$ReturnFieldFooter};
            }

            # add background color to maintenance text / warning box
            my $SearchWarning = quotemeta "<div class=\"WarningBox WithIcon\">";
            my $ReturnWarning = qq~<div class="WarningBox WithIcon" style="background-color:#deb887;">
            ~;

            #search and replace
            ${ $Param{Data} } =~ s{$SearchWarning}{$ReturnWarning};

            my %CustomerLoginAlert = %{ $ConfigObject->Get('CustomerLoginAlert') };

            if ( $CustomerLoginAlert{'Alert'} )
            {
                my $SearchAlert = quotemeta "<noscript>";
                my $ReturnAlert
                    = qq~<div class="MessageBox WithIcon" id="Alert" style="background-color: $CustomerLoginAlert{'AlertBackground'};"><p style="color: $CustomerLoginAlert{'AlertTextColor'}">$CustomerLoginAlert{'AlertText'}</p></div>
                <noscript>
                ~;

                #search and replace
                ${ $Param{Data} } =~ s{$SearchAlert}{$ReturnAlert};
            }

            #color
            my %CustomerLoginBackgroundColor = %{ $ConfigObject->Get('CustomerLoginBackgroundColor') };

            #check if container color need to change
            if ( $CustomerLoginBackgroundColor{'ContainerBackgroundColor'} )
            {
                # background color to container (login/reset/register)
                my $SearchContainer = quotemeta "<div id=\"Container\">";
                my $ReturnContainer
                    = qq~<div id="Container" style="background: $CustomerLoginBackgroundColor{'ContainerBackgroundColor'};">
                ~;

                #search and replace
                ${ $Param{Data} } =~ s{$SearchContainer}{$ReturnContainer};
            }

            #check if text header h2 color need to change
            if ( $CustomerLoginBackgroundColor{'TextHeaderColor'} )
            {
                #h2 header color
                for my $Header2 ( 'Login', 'Request New Password', 'Create Account' )
                {
                    my $SearchH2 = quotemeta "<h2>$Header2</h2>";
                    my $ReturnH2 = qq~<h2 style="color: $CustomerLoginBackgroundColor{'TextHeaderColor'};">$Header2</h2>
                    ~;

                    ${ $Param{Data} } =~ s{$SearchH2}{$ReturnH2};
                }
            }

            #check if label color need to change
            if ( $CustomerLoginBackgroundColor{'LabelColor'} )
            {
                #label color
                for my $Optional (qw( User Password TwoFactorToken ResetUser Title ))
                {
                    my $SearchLabel = quotemeta "<label for=\"$Optional\">";
                    my $ReturnLabel
                        = qq~<label for="$Optional" style="color: $CustomerLoginBackgroundColor{'LabelColor'}">
                    ~;

                    ${ $Param{Data} } =~ s{$SearchLabel}{$ReturnLabel};
                }

                #mandatory label color
                for my $Required (qw( FirstName LastName Email ))
                {
                    my $SearchLabel = quotemeta "<label class=\"Mandatory\" for=\"$Required\">";
                    my $ReturnLabel
                        = qq~<label class="Mandatory" for="$Required" style="color: $CustomerLoginBackgroundColor{'LabelColor'} !important">
                    ~;

                    ${ $Param{Data} } =~ s{$SearchLabel}{$ReturnLabel};
                }

            }

        }

    }

# ---

    return 1;
}

1;
