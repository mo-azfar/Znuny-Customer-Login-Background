# --
# Copyright (C) 2023 mo-azfar,https://github.com/mo-azfar
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
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

    my $ConfigObject                    = $Kernel::OM->Get('Kernel::Config');
    #my $ParamObject                     = $Kernel::OM->Get('Kernel::System::Web::Request');
	
	# --
	# Customer Login Background
	# --
	if ( $Param{TemplateFile} eq 'CustomerLogin')
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
				my $ReturnFieldHeader = qq~<div id="Header" style="background:transparent; border-bottom-color:transparent;">~;
				
				#search and replace	
				${ $Param{Data} } =~ s{$SearchFieldHeader}{$ReturnFieldHeader};
			}
			
			#check if transparent footer is needed
			if ( $Data{'TransparentFooter'} )
			{
				#set footer background as transparent
				my $SearchFieldFooter = quotemeta "<div id=\"Footer\" class=\"ARIARoleContentinfo\">";
				my $ReturnFieldFooter = qq~ <div id="Footer" class="ARIARoleContentinfo" style="background:transparent; border-top-color:transparent;"> ~;
				
				#search and replace	
				${ $Param{Data} } =~ s{$SearchFieldFooter}{$ReturnFieldFooter};
			}

            # add background color to maintenance text / warning box
			my $SearchWarning = quotemeta "<div class=\"WarningBox WithIcon\">";
			my $ReturnWarning = qq~<div class="WarningBox WithIcon" style="background-color:#deb887;">
			~;

            #search and replace	
			${ $Param{Data} } =~ s{$SearchWarning}{$ReturnWarning};

            #color
            my %CustomerLoginBackgroundColor = %{ $ConfigObject->Get('CustomerLoginBackgroundColor') };

            #check if container color need to change
            if ( $CustomerLoginBackgroundColor{'ContainerBackgroundColor'} )
            {
                # background color to container (login/reset/register)
                my $SearchContainer = quotemeta "<div id=\"Container\">";
                my $ReturnContainer = qq~<div id="Container" style="background: $CustomerLoginBackgroundColor{'ContainerBackgroundColor'};">
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
                    my $ReturnH2 =  qq~<h2 style="color: $CustomerLoginBackgroundColor{'TextHeaderColor'};">$Header2</h2>
                    ~; 

                    ${ $Param{Data} } =~ s{$SearchH2}{$ReturnH2};  
                }
            }

             #check if label color need to change
            if ( $CustomerLoginBackgroundColor{'LabelColor'} )
            {
               #label color
                for my $Optional ( qw( User Password ResetUser Title ) )
                {
                    my $SearchLabel = quotemeta "<label for=\"$Optional\">";
                    my $ReturnLabel =  qq~<label for="$Optional" style="color: $CustomerLoginBackgroundColor{'LabelColor'}">
                    ~; 

                    ${ $Param{Data} } =~ s{$SearchLabel}{$ReturnLabel};  
                }

                #mandatory label color
                for my $Required ( qw( FirstName LastName Email ) )
                {
                    my $SearchLabel = quotemeta "<label class=\"Mandatory\" for=\"$Required\">";
                    my $ReturnLabel =  qq~<label class="Mandatory" for="$Required" style="color: $CustomerLoginBackgroundColor{'LabelColor'} !important">
                    ~; 

                    ${ $Param{Data} } =~ s{$SearchLabel}{$ReturnLabel};  
                }

            }
               
        }        
		
    }  
	# --
	
    return 1;
}

1;
