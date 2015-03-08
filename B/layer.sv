
package layer;

    typedef enum {READ, WRITE} rw_t;
    
class addr_txn;
    rand bit [31:0] addr;
    rand int size;

    constraint c_size { size inside {1,2,4}; }
endclass
    
class rw_txn extends addr_txn;
    rand rw_t op;

    function void rprint();
        this.randomize();
        this.print();        
    endfunction

    function void print();
        $display("  addr=%h size=%0d", this.addr, this.size);
    endfunction
    
endclass

class addr_permit;
    rand bit [31:0] addr;
    rand int size;
    constraint c_addr_permit {
        addr inside {['h00000000 : 'h0000FFFF - size]} ||
        addr inside {['h10000000 : 'h1FFFFFFF - size]};        
    }
endclass

class addr_prohibit;
    rand bit [31:0] addr;
    rand int size;
    constraint c_addr_prohibit {
        !(addr inside {['h00000000 : 'h00000FFF - size]});        
    }
endclass

class rw_constrained_txn extends rw_txn;
    rand addr_permit permit = new;
    rand addr_prohibit prohibit = new;

    constraint c_all {
        this.addr == permit.addr;
        this.addr == prohibit.addr;

        this.size == permit.size;
        this.size == prohibit.size;
    };
    
endclass
    
endpackage    

module TB ();

    import layer::*;
    
    layer::rw_txn rw_txn;
    layer::rw_constrained_txn rw_constrained_txn;
    
    initial begin
        rw_txn = new;
        rw_constrained_txn = new;
        
        $display("\nFIGURE 4. Read/Write transaction with addres constraints in seperate container classes:");
        for (int i = 0; i < 5; i++) begin
            rw_constrained_txn.rprint();
        end
        
    end
   
endmodule
