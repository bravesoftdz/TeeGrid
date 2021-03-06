{*********************************************}
{  TeeGrid Software Library                   }
{  Grid Header class                          }
{  Copyright (c) 2016 by Steema Software      }
{  All Rights Reserved                        }
{*********************************************}
unit Tee.Grid.Header;
{$I Tee.inc}

interface

{
  Custom Grid Band classes to display content for Columns.

    TColumnBand :

      Base abstract class for grid bands with Columns.

      Provides:

         Column mouse-dragging
         Mouse-hover highlighting
         Horizontal scrolling

    TColumnHeaderBand :

      Implements a TeeGrid Header (to show column names) with multiple
      sub-levels if the columns have sub-columns.

      Includes a stroke "RowLines" property to paint lines between sub-levels.


  Needs: Tee.Painter, Tee.Format, Tee.Renders, Tee.Grid.Bands and Tee.Grid.Columns
}


uses
  {System.}Classes,

  {$IFNDEF FPC}
  {System.}Types,
  {$ENDIF}

  Tee.Painter, Tee.Format, Tee.Renders,
  Tee.Grid.Columns, Tee.Grid.Bands, Tee.Grid.Data;

type
  // Grid band with Columns
  TColumnBand=class(TGridBandLines)
  private
    FHover: THover;
    FOnColumnResized: TNotifyEvent;

    IDragging  : TColumn;
    IHighLight : TColumn;

    OldWidth,
    OldX : Single;

    procedure ChangeDraggedWidth(const AValue:Single);
    procedure PaintLines(var AData:TRenderData; const DrawFirst:Boolean);
    procedure SetHighLight(const Value: TColumn);
    procedure SetHover(const Value: THover);
    procedure SetColumns(const Value: TColumns);
  protected
    IColumns : TColumns;

    function AdjustBounds(const AColumn:TColumn; const R:TRectF):TRectF; virtual;
    function AsString(const AColumn:TColumn):String; virtual; abstract;
    procedure DoClick; virtual;
  public
    MouseColumn : TColumn; // current column under mouse XY

    Width : Single;

    // Temporary
    MinX,
    OffsetX,
    StartX : Single;

    Constructor Create(const AChanged:TNotifyEvent; const AColumns:TColumns); reintroduce; virtual;

    {$IFNDEF AUTOREFCOUNT}
    Destructor Destroy; override;
    {$ENDIF}

    function CalcFont(const AColumn:TColumn):TFont;
    procedure InitFormat;

    function Mouse(var AState:TMouseState; const AWidth,AHeight:Single):Boolean; override;

    procedure Paint(var AData:TRenderData); override;

    property Columns:TColumns read IColumns write SetColumns;

    // Current column being dragged
    property Dragging:TColumn read IDragging write IDragging;

    // Current column to highlight
    property HighLight:TColumn read IHighLight write SetHighLight;
  published
    property Hover:THover read FHover write SetHover;
    property OnColumnResized:TNotifyEvent read FOnColumnResized write FOnColumnResized;
  end;

  TSortState=(None,Ascending,Descending);

  TSortableHeader=class(TFormatRender)
  private
    const
      DefaultSize=6;

    var
      FSize: Single;

    function IsSizeStored: Boolean;
    procedure SetSize(const Value: Single);
  public
    State : TSortState;

    Constructor Create(const AChanged:TNotifyEvent); override;

    function Hit(const R:TRectF; const X,Y:Single):Boolean; override;
    procedure Paint(var AData:TRenderData); override;
  published
    property Size:Single read FSize write SetSize stored IsSizeStored;
  end;

  // Grid Header main class
  TColumnHeaderBand=class(TColumnBand)
  private
    FRowLines : TStroke;
    FSortable: Boolean;

    IData : TVirtualData;

    function LevelTop(const ALevel:Integer):Single;
    procedure PaintRowLines(const APainter:TPainter; const AColumns:TColumns; const ALevel:Integer);
    procedure SetRowLines(const Value: TStroke);
    procedure SetSortable(const Value: Boolean);
  protected
    function AdjustBounds(const AColumn:TColumn; const R:TRectF):TRectF; override;
    function AsString(const AColumn:TColumn):String; override;
    procedure DoClick; override;
  public
    const
      RowSpacing=4;

    var
      Render : TSortableHeader;

    Constructor Create(const AChanged:TNotifyEvent;
                       const AColumns:TColumns;
                       const AData:TVirtualData); reintroduce; virtual;

    {$IFNDEF AUTOREFCOUNT}
    Destructor Destroy; override;
    {$ENDIF}

    function AutoWidth(const APainter:TPainter; const AColumn:TColumn):Single;
    procedure CalcHeight(const ATotal:Single); override;
    function CanSort(const AColumn:TColumn):Boolean;

    procedure Paint(var AData:TRenderData); override;

    function RowCount:Integer;

    property Data:TVirtualData read IData write IData;
  published
    property RowLines:TStroke read FRowLines write SetRowLines;
    property Sortable:Boolean read FSortable write SetSortable default True;
  end;

implementation
